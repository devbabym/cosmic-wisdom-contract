;; Cosmic Wisdom Repository Contract
;; A system for tracking and managing cosmic insights and discoveries
;; across the universe of knowledge domains

;; =========================================
;; Global Configuration Constants
;; =========================================
;; Central authority identification
(define-constant GALAXY-OVERSEER tx-sender)

;; System Response Signal Codes
(define-constant ERROR-COSMIC-INSIGHT-SCALE-INVALID (err u304))
(define-constant ERROR-UNAUTHORIZED-STARGAZER (err u305))
(define-constant ERROR-INVALID-KNOWLEDGE-RECIPIENT (err u306))
(define-constant ERROR-OVERSEER-ONLY-FUNCTION (err u307))
(define-constant ERROR-OBSERVATION-RIGHTS-MISSING (err u308))
(define-constant ERROR-INSIGHT-NOT-FOUND (err u301))
(define-constant ERROR-INSIGHT-EXISTS-ALREADY (err u302))
(define-constant ERROR-INSIGHT-TITLE-MALFORMED (err u303))

;; =========================================
;; Repository State Management
;; =========================================
;; Observation rights ledger
(define-map observation-privileges
  { insight-key: uint, observer: principal }
  { can-observe: bool }
)

;; Running counter of recorded insights
(define-data-var universal-insight-counter uint u0)

;; Primary repository of cosmic insights
(define-map cosmic-insights-archive
  { insight-key: uint }
  {
    title: (string-ascii 64),
    discoverer: principal,
    magnitude: uint,
    discovery-epoch: uint,
    observation-notes: (string-ascii 128),
    knowledge-domains: (list 10 (string-ascii 32))
  }
)

;; =========================================
;; Helper Functions for Data Verification
;; =========================================
;; Checks if a cosmic insight has been recorded
(define-private (insight-exists? (insight-key uint))
  (is-some (map-get? cosmic-insights-archive { insight-key: insight-key }))
)

;; Confirms if a stargazer is the original discoverer
(define-private (is-original-discoverer? (insight-key uint) (discoverer principal))
  (match (map-get? cosmic-insights-archive { insight-key: insight-key })
    insight-record (is-eq (get discoverer insight-record) discoverer)
    false
  )
)
;; Ensures text fields meet length constraints
(define-private (validate-textual-field (field-content (string-ascii 64)) (min-length uint) (max-length uint))
  (and 
    (>= (len field-content) min-length)
    (<= (len field-content) max-length)
  )
)

;; Increments and returns the previous repository counter value
(define-private (increment-insight-counter)
  (let ((existing-value (var-get universal-insight-counter)))
    (var-set universal-insight-counter (+ existing-value u1))
    (ok existing-value)
  )
)

;; Retrieves the magnitude measurement of an insight
(define-private (fetch-insight-magnitude (insight-key uint))
  (default-to u0 
    (get magnitude 
      (map-get? cosmic-insights-archive { insight-key: insight-key })
    )
  )
)

;; Validates knowledge domain descriptors
(define-private (validate-knowledge-domain? (domain (string-ascii 32)))
  (and 
    (> (len domain) u0)
    (< (len domain) u33)
  )
)

;; Ensures all knowledge domains meet requirements
(define-private (validate-all-knowledge-domains? (domains (list 10 (string-ascii 32))))
  (and
    (> (len domains) u0)
    (<= (len domains) u10)
    (is-eq (len (filter validate-knowledge-domain? domains)) (len domains))
  )
)


;; =========================================
;; Primary Public Repository Functions
;; =========================================
;; Documents a new cosmic insight in the archive
(define-public (document-cosmic-insight (title (string-ascii 64)) (magnitude uint) (observation-notes (string-ascii 128)) (knowledge-domains (list 10 (string-ascii 32))))
  (let
    (
      (next-insight-id (+ (var-get universal-insight-counter) u1))
    )
    ;; Perform comprehensive validation of input parameters
    (asserts! (and (> (len title) u0) (< (len title) u65)) ERROR-INSIGHT-TITLE-MALFORMED)
    (asserts! (and (> magnitude u0) (< magnitude u1000000000)) ERROR-COSMIC-INSIGHT-SCALE-INVALID)
    (asserts! (and (> (len observation-notes) u0) (< (len observation-notes) u129)) ERROR-INSIGHT-TITLE-MALFORMED)
    (asserts! (validate-all-knowledge-domains? knowledge-domains) ERROR-INSIGHT-TITLE-MALFORMED)

    ;; Record the cosmic insight details
    (map-insert cosmic-insights-archive
      { insight-key: next-insight-id }
      {
        title: title,
        discoverer: tx-sender,
        magnitude: magnitude,
        discovery-epoch: block-height,
        observation-notes: observation-notes,
        knowledge-domains: knowledge-domains
      }
    )

    ;; Grant observation privileges to the discoverer
    (map-insert observation-privileges
      { insight-key: next-insight-id, observer: tx-sender }
      { can-observe: true }
    )

    ;; Update the universal insight counter
    (var-set universal-insight-counter next-insight-id)
    (ok next-insight-id)
  )
)

;; Retrieves observational notes about a specific insight
(define-public (access-insight-notes (insight-key uint))
  (let
    (
      (insight-record (unwrap! (map-get? cosmic-insights-archive { insight-key: insight-key }) ERROR-INSIGHT-NOT-FOUND))
    )
    (ok (get observation-notes insight-record))
  )
)

;; Verifies if an observer has proper credentials for a specific insight
(define-public (verify-observer-credentials (insight-key uint) (observer principal))
  (let
    (
      (credentials (map-get? observation-privileges { insight-key: insight-key, observer: observer }))
    )
    (ok (is-some credentials))
  )
)

;; Counts the knowledge domains associated with an insight
(define-public (count-insight-domains (insight-key uint))
  (let
    (
      (insight-record (unwrap! (map-get? cosmic-insights-archive { insight-key: insight-key }) ERROR-INSIGHT-NOT-FOUND))
    )
    (ok (len (get knowledge-domains insight-record)))
  )
)

;; Validates cosmic insight title format compliance
(define-public (verify-title-compliance (title (string-ascii 64)))
  (ok (and (> (len title) u0) (<= (len title) u64)))
)

;; Transfers discovery attribution to another stargazer
(define-public (transfer-insight-attribution (insight-key uint) (new-discoverer principal))
  (let
    (
      (insight-record (unwrap! (map-get? cosmic-insights-archive { insight-key: insight-key }) ERROR-INSIGHT-NOT-FOUND))
    )
    (asserts! (insight-exists? insight-key) ERROR-INSIGHT-NOT-FOUND)
    (asserts! (is-eq (get discoverer insight-record) tx-sender) ERROR-UNAUTHORIZED-STARGAZER)

    ;; Update attribution records
    (map-set cosmic-insights-archive
      { insight-key: insight-key }
      (merge insight-record { discoverer: new-discoverer })
    )
    (ok true)
  )
)

;; Updates the metadata for an existing cosmic insight
(define-public (revise-insight-record (insight-key uint) (revised-title (string-ascii 64)) (revised-magnitude uint) (revised-notes (string-ascii 128)) (revised-domains (list 10 (string-ascii 32))))
  (let
    (
      (insight-record (unwrap! (map-get? cosmic-insights-archive { insight-key: insight-key }) ERROR-INSIGHT-NOT-FOUND))
    )
    ;; Validate inputs and permissions
    (asserts! (insight-exists? insight-key) ERROR-INSIGHT-NOT-FOUND)
    (asserts! (is-eq (get discoverer insight-record) tx-sender) ERROR-UNAUTHORIZED-STARGAZER)
    (asserts! (and (> (len revised-title) u0) (< (len revised-title) u65)) ERROR-INSIGHT-TITLE-MALFORMED)
    (asserts! (and (> revised-magnitude u0) (< revised-magnitude u1000000000)) ERROR-COSMIC-INSIGHT-SCALE-INVALID)
    (asserts! (and (> (len revised-notes) u0) (< (len revised-notes) u129)) ERROR-INSIGHT-TITLE-MALFORMED)
    (asserts! (validate-all-knowledge-domains? revised-domains) ERROR-INSIGHT-TITLE-MALFORMED)

    ;; Apply comprehensive updates to the insight record
    (map-set cosmic-insights-archive
      { insight-key: insight-key }
      (merge insight-record { 
        title: revised-title, 
        magnitude: revised-magnitude, 
        observation-notes: revised-notes, 
        knowledge-domains: revised-domains 
      })
    )
    (ok true)
  )
)

;; Completely removes an insight from the cosmic archive
(define-public (erase-cosmic-insight (insight-key uint))
  (let
    (
      (insight-record (unwrap! (map-get? cosmic-insights-archive { insight-key: insight-key }) ERROR-INSIGHT-NOT-FOUND))
    )
    (asserts! (insight-exists? insight-key) ERROR-INSIGHT-NOT-FOUND)
    (asserts! (is-eq (get discoverer insight-record) tx-sender) ERROR-UNAUTHORIZED-STARGAZER)

    ;; Permanently remove the insight from the archive
    (map-delete cosmic-insights-archive { insight-key: insight-key })
    (ok true)
  )
)


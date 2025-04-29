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

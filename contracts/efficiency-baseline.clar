;; efficiency-baseline.clar
;; Establishes pre-improvement performance

(define-data-var contract-owner principal tx-sender)

;; Data structure for efficiency baselines
(define-map efficiency-baselines
  { system-id: uint }
  {
    energy-consumption-kwh: uint,
    operational-hours: uint,
    efficiency-rating: uint,
    measurement-date: uint,
    verified-by: principal
  }
)

;; Check if caller is contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

;; Set baseline efficiency for a system
(define-public (set-baseline
    (system-id uint)
    (energy-consumption-kwh uint)
    (operational-hours uint)
    (efficiency-rating uint))
  (begin
    (asserts! (is-contract-owner) (err u403))
    (map-set efficiency-baselines
      { system-id: system-id }
      {
        energy-consumption-kwh: energy-consumption-kwh,
        operational-hours: operational-hours,
        efficiency-rating: efficiency-rating,
        measurement-date: block-height,
        verified-by: tx-sender
      }
    )
    (ok true)
  )
)

;; Get baseline efficiency for a system
(define-read-only (get-baseline (system-id uint))
  (map-get? efficiency-baselines { system-id: system-id })
)

;; Transfer ownership of the contract
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner) (err u403))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

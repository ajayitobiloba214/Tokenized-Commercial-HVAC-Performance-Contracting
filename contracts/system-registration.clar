;; system-registration.clar
;; Records details of climate control equipment

(define-data-var contract-owner principal tx-sender)

;; Data structure for HVAC systems
(define-map hvac-systems
  { system-id: uint }
  {
    owner: principal,
    system-type: (string-utf8 50),
    location: (string-utf8 100),
    capacity-kw: uint,
    installation-date: uint,
    registration-date: uint
  }
)

;; Counter for system IDs
(define-data-var next-system-id uint u1)

;; Check if caller is contract owner
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

;; Register a new HVAC system
(define-public (register-system
    (system-type (string-utf8 50))
    (location (string-utf8 100))
    (capacity-kw uint)
    (installation-date uint))
  (let
    (
      (system-id (var-get next-system-id))
    )
    (asserts! (is-contract-owner) (err u403))
    (map-insert hvac-systems
      { system-id: system-id }
      {
        owner: tx-sender,
        system-type: system-type,
        location: location,
        capacity-kw: capacity-kw,
        installation-date: installation-date,
        registration-date: block-height
      }
    )
    (var-set next-system-id (+ system-id u1))
    (ok system-id)
  )
)

;; Get HVAC system details
(define-read-only (get-system (system-id uint))
  (map-get? hvac-systems { system-id: system-id })
)

;; Transfer ownership of the contract
(define-public (transfer-ownership (new-owner principal))
  (begin
    (asserts! (is-contract-owner) (err u403))
    (var-set contract-owner new-owner)
    (ok true)
  )
)

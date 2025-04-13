;; MedicalDevice Smart Contract
;; Enables transparent tracking of medical device lifecycle and certifications

(define-trait medical-device-tracking-trait
  (
    (register-device (uint uint) (response bool uint))
    (update-device-status (uint uint) (response bool uint))
    (get-device-history (uint) (response (list 10 {status: uint, timestamp: uint}) uint))
    (add-certification (uint uint principal) (response bool uint))
    (verify-certification (uint uint) (response bool uint))
  )
)


;; Define device status constants
(define-constant DEVICE_STATUS_MANUFACTURED u1)
(define-constant DEVICE_STATUS_TESTING u2)
(define-constant DEVICE_STATUS_DEPLOYED u3)
(define-constant DEVICE_STATUS_MAINTAINED u4)

;; token definitions
;;
;; Define certification type constants
(define-constant CERT_TYPE_FDA u1)
(define-constant CERT_TYPE_CE u2)
(define-constant CERT_TYPE_ISO u3)
(define-constant CERT_TYPE_SAFETY u4)


;;
;; Error constants
(define-constant ERR_UNAUTHORIZED (err u1))
(define-constant ERR_INVALID_DEVICE (err u2))
(define-constant ERR_STATUS_UPDATE_FAILED (err u3))
(define-constant ERR_INVALID_STATUS (err u4))
(define-constant ERR_INVALID_CERTIFICATION (err u5))
(define-constant ERR_CERTIFICATION_EXISTS (err u6))

;; data vars
;;
;; Contract owner
(define-data-var contract-owner principal tx-sender)

;; data maps
;;
;; Current timestamp counter
(define-data-var timestamp-counter uint u0)

;; public functions
;;
;; Device tracking map
(define-map device-details 
  {device-id: uint} 
  {
    owner: principal,
    current-status: uint,
    history: (list 10 {status: uint, timestamp: uint})
  }
)

;; Certification tracking map
(define-map device-certifications
  {device-id: uint, cert-type: uint}
  {
    issuer: principal,
    timestamp: uint,
    valid: bool
  }
)

;; Validate status
(define-private (is-valid-status (status uint))
  (or 
    (is-eq status DEVICE_STATUS_MANUFACTURED)
    (is-eq status DEVICE_STATUS_TESTING)
    (is-eq status DEVICE_STATUS_DEPLOYED)
    (is-eq status DEVICE_STATUS_MAINTAINED)
  )
)

;; Validate certification type
(define-private (is-valid-certification-type (cert-type uint))
  (or
    (is-eq cert-type CERT_TYPE_FDA)
    (is-eq cert-type CERT_TYPE_CE)
    (is-eq cert-type CERT_TYPE_ISO)
    (is-eq cert-type CERT_TYPE_SAFETY)
  )
)


;; Validate authority principal
(define-private (is-valid-authority (authority principal))
  (and 
    (not (is-eq authority (var-get contract-owner)))  
    (not (is-eq authority tx-sender))                
    (not (is-eq authority 'SP000000000000000000002Q6VF78))  
  )
)


;; Validate device ID
(define-private (is-valid-device-id (device-id uint))
  (and (> device-id u0) (<= device-id u1000000))
)


;; Approved regulatory bodies
(define-map regulatory-bodies
  {authority: principal, cert-type: uint}
  {approved: bool}
)

;; Get current timestamp and increment counter
(define-private (get-current-timestamp)
  (begin
    (var-set timestamp-counter (+ (var-get timestamp-counter) u1))
    (var-get timestamp-counter)
  )
)

;; Only contract owner can perform certain actions
(define-read-only (is-contract-owner (sender principal))
  (is-eq sender (var-get contract-owner))
)


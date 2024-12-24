;; sensors-registry.clar
(define-constant sensors-registry-contract 'ST123456.sensor-registry) ;; Replace ST123456 with your actual testnet deployer address

;; Sensor management and registration contract for Smart Farming IoT System

(define-map sensor-registry
    principal  ;; sensor principal
    {
        sensor-type: (string-utf8 32),
        location: (string-utf8 64),
        installation-date: uint,
        last-maintenance: uint,
        is-active: bool,
        firmware-version: (string-utf8 16)
    }
)

(define-map maintenance-history
    {sensor: principal, maintenance-id: uint}
    {
        maintenance-type: (string-utf8 32),
        maintenance-date: uint,
        performed-by: principal,
        notes: (string-utf8 256)
    }
)

(define-data-var maintenance-counter uint u0)
(define-data-var registry-admin principal tx-sender)

;; Administrator functions
(define-public (set-registry-admin (new-admin principal))
    (begin
        (asserts! (is-eq tx-sender (var-get registry-admin)) (err u403))
        (ok (var-set registry-admin new-admin))
    )
)

;; Sensor Registration Functions
(define-public (register-sensor
    (sensor-principal principal)
    (sensor-type (string-utf8 32))
    (location (string-utf8 64))
    (firmware-version (string-utf8 16))
)
    (begin
        (asserts! (is-eq tx-sender (var-get registry-admin)) (err u403))
        (ok (map-set sensor-registry
            sensor-principal
            {
                sensor-type: sensor-type,
                location: location,
                installation-date: block-height,
                last-maintenance: block-height,
                is-active: true,
                firmware-version: firmware-version
            }
        ))
    )
)

;; Maintenance Functions
(define-public (record-maintenance
    (sensor-principal principal)
    (maintenance-type (string-utf8 32))
    (notes (string-utf8 256))
)
    (let
        (
            (maintenance-id (var-get maintenance-counter))
            (sensor-data (unwrap! (map-get? sensor-registry sensor-principal) (err u404)))
        )
        (begin
            (asserts! (is-eq tx-sender (var-get registry-admin)) (err u403))
            (var-set maintenance-counter (+ maintenance-id u1))
            (map-set maintenance-history
                {sensor: sensor-principal, maintenance-id: maintenance-id}
                {
                    maintenance-type: maintenance-type,
                    maintenance-date: block-height,
                    performed-by: tx-sender,
                    notes: notes
                }
            )
            (ok (map-set sensor-registry
                sensor-principal
                (merge sensor-data {last-maintenance: block-height})
            ))
        )
    )
)

;; Query Functions
(define-read-only (get-sensor-details (sensor-principal principal))
    (map-get? sensor-registry sensor-principal)
)

(define-read-only (get-maintenance-record 
    (sensor-principal principal)
    (maintenance-id uint)
)
    (map-get? maintenance-history
        {sensor: sensor-principal, maintenance-id: maintenance-id}
    )
)

;; Status Management
(define-public (update-sensor-status
    (sensor-principal principal)
    (is-active bool)
)
    (let
        ((sensor-data (unwrap! (map-get? sensor-registry sensor-principal) (err u404))))
        (begin
            (asserts! (is-eq tx-sender (var-get registry-admin)) (err u403))
            (ok (map-set sensor-registry
                sensor-principal
                (merge sensor-data {is-active: is-active})
            ))
        )
    )
)

;; extends

;; blade
((php) @injection.content
    (#set! injection.combined)
    (#set! injection.language php))

((php_only) @injection.content
   (#set! injection.combined)
   (#set! injection.language php))

; directive parameters
((parameter) @injection.content
   (#set! injection.language php))

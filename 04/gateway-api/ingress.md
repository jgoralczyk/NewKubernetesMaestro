# INGRESS

## Routing na bazie ścieżki

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: weather-api-svc
            port:
              number: 80
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: passage-v2-webapp-svc
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: passage-webapp-svc
            port:
              number: 80
```

## Charakterystyka

- Wszystko w jednym zasobie
- Prostsze dla podstawowych przypadków
- Brak separacji ról (ops + dev w jednym YAML)
- IngressClass vendor-specific


## Terminacja TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: demo-ingress-tls
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - myapp.example.com
    secretName: myapp-tls
  rules:
  - host: myapp.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-svc
            port:
              number: 80
```

**Konfiguracja TLS:**
- Głównie do prostych / podstawowych przypadków
- Zaawansowane opcje wymagają użycia adnotacji (specyficznych dla dostawcy Ingress Controllera)

## Advanced Routing

### Header-based routing
```yaml
metadata:
  annotations:
    nginx.org/server-snippets: |
      if ($http_api_version = "v2") {
        rewrite ^/api/(.*)$ /v2/$1 break;
      }
```
Wymaga specyficznych snippetów w zależności od tego, jaki Ingress Controller używamy

### Podział Ruchu (przykład Canary Release)
```yaml
metadata:
  annotations:
    nginx.org/canary: "true"
    nginx.org/canary-weight: "10"
```
Znowu - specyficzne snippety (adnotacje per dostawca Ingress Controllera)

### Query Parameters
Nie wspierane natywnie - wymaga custom NGINX config

## Multi-Protocol Support

- HTTP/HTTPS
- TCP/UDP - wymaga ConfigMap hacks
- gRPC - limited support

## Przenośność

```yaml
annotations:
  nginx.org/rewrites: "serviceName=weather-api-svc rewrite=/"
  nginx.org/ssl-redirect: "false"
```

Adnotacje specyficzne dla Ingress Controllera jaki mamy zainstalowany

## Kiedy używać?

**Dobre dla:**
- Prosty HTTP routing (path/host)
- Legacy systemy które już używają Ingress
- Mały zespół, mały klaster
- Brak planów zmiany cloud providera

**Kiedy lepiej iść w Gateway API:**
- Multi-tenant klaster z wieloma zespołami
- Protokoły inne niż HTTP (TCP/UDP/gRPC)
- Zaawansowane przypadki wymuszania TLS 

## Podsumowanie

- Prosty, sprawdzony, wystarczający dla większości przypadków
- Dobry wybór dla prostych aplikacji

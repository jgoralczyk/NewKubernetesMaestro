# GATEWAY API

## Routing na bazie ścieżki

```yaml
# 1. Gateway (tworzy ops/platform team - raz)
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway
spec:
  gatewayClassName: eg
  listeners:
  - name: http
    protocol: HTTP
    port: 80

---
# 2. HTTPRoute (tworzy dev team - dla każdej aplikacji)
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-routes
spec:
  parentRefs:
  - name: demo-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: weather-api-svc
      port: 80

  - matches:
    - path:
        type: PathPrefix
        value: /v2
    backendRefs:
    - name: passage-v2-webapp-svc
      port: 80

  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: passage-webapp-svc
      port: 80
```

## Charakterystyka

- Separacja ról (Gateway tworzy ops, HTTPRoute developer)
- Przenośny - działa na różnych implementacjach bez zmian
- Rozszerzalny - łatwo dodać nowe funkcjonalności
- Więcej zasobów do zarządzania

## Architektura

```
┌─────────────────────┐
│   GatewayClass      │ ← Platform Admin
├─────────────────────┤
│   Gateway           │ ← Cluster Operator
├─────────────────────┤
│   HTTPRoute         │ ← App Developer
└─────────────────────┘
```

## Terminacja TLS

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: demo-gateway-tls
spec:
  gatewayClassName: eg
  listeners:
  - name: https
    protocol: HTTPS
    port: 443
    tls:
      mode: Terminate
      certificateRefs:
      - name: myapp-tls
    allowedRoutes:
      namespaces:
        from: Selector
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-routes
spec:
  parentRefs:
  - name: demo-gateway-tls
  rules:
  - backendRefs:
    - name: app-svc
      port: 80
```

**Konfiguracja TLS:**
- Separacja: TLS konfiguruje ops w Gateway, developer pisze tylko routing w HTTPRoute
- Możliwość wielu listenerów z różnymi certyfikatami
- Tryby Terminate/Passthrough dostępne natywnie
- allowedRoutes - kontrola kto może podpiąć swoje Route do Gateway

## Advanced Routing

### Header-based routing
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-routing
spec:
  parentRefs:
  - name: demo-gateway
  rules:
  - matches:
    - headers:
      - name: api-version
        value: v2
      path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: api-v2-svc
      port: 80
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: api-v1-svc
      port: 80
```
Routing bazujący na headerach jest natywnie dostępny w specyfikacji - czytelny i przenośny

### Podział Ruchu (przykład Canary Release)
```yaml
rules:
- backendRefs:
  - name: app-stable
    port: 80
    weight: 90
  - name: app-canary
    port: 80
    weight: 10
```
Podział ruchu jest wbudowany w backendRefs - nie potrzeba adnotacji

### Query Parameters
```yaml
rules:
- matches:
  - queryParams:
    - name: version
      value: beta
    backendRefs:
    - name: beta-backend
      port: 80
```
Routing bazujący na parametrach zapytania działa od razu

## Wsparcie Wielu Protokołów

### HTTP/HTTPS
```yaml
kind: HTTPRoute
```

### TCP
```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: postgres-route
spec:
  parentRefs:
  - name: tcp-gateway
  rules:
  - backendRefs:
    - name: postgres-svc
      port: 5432
```

### gRPC
```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: GRPCRoute
metadata:
  name: grpc-route
spec:
  parentRefs:
  - name: demo-gateway
  rules:
  - backendRefs:
    - name: grpc-svc
      port: 9090
```

Dedykowane typy tras dla każdego protokołu

## Przenośność

```yaml
# Brak adnotacji!
# Wszystko w standardowej specyfikacji
```

Przenośny między implementacjami - ten sam YAML działa na Envoy Gateway, Istio, Cilium, Kong, Traefik

## Kiedy używać?

**Dobre dla:**
- Nowe projekty
- Klaster dla wielu zespołów (separacja ról jest kluczowa)
- Zaawansowany routing (headery, parametry zapytań, wagi)
- Różne protokoły (HTTP + gRPC + TCP)
- Przenośna konfiguracja - możliwość zmiany implementacji
- Długoterminowa utrzymywalność

**Kiedy lepiej zostać przy Ingress:**
- Bardzo prosty przypadek użycia
- Zespół nie ma czasu na naukę nowego API

## Podsumowanie

- Nowoczesny, rozszerzalny, przenośny
- Lepszy dla złożonych środowisk i nowych projektów

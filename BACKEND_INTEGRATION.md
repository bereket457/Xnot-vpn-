# Xnot VPN — Authorized backend integration

Production architecture:

Flutter app
→ HTTPS control plane (optional)
→ authorized VPN gateway / WireGuard server
→ Internet

A control plane can provision a unique WireGuard client configuration per device.

The client itself should receive only the client private key and the server peer public key/endpoint needed for its assigned tunnel.

This project intentionally does not contain payload injection, SNI spoofing, telecom restriction bypass, or carrier-policy evasion.

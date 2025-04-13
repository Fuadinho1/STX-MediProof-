
# Stacks Medical Device Tracking Smart Contract

## Overview

This Clarity smart contract is designed to provide **transparent, secure, and auditable tracking** of medical devices through their lifecycle stages, along with associated certifications. It ensures that only authorized entities (like manufacturers and regulatory bodies) can interact with the contract in specific, validated ways.

---

## 📦 Contract Metadata

- **Title**: `meddev`
- **Version**: `1.0.0`
- **Summary**: A Clarity smart contract for managing the lifecycle and certification of medical devices.
- **Author**: N/A
- **License**: MIT (suggested, please update accordingly)

---

## 🛠 Features

- Register medical devices with initial status.
- Track lifecycle status changes (e.g., Manufactured → Deployed).
- Maintain a history log of status changes.
- Add and verify certifications from approved regulatory bodies.
- Revoke device certifications.
- Access device data through read-only queries.

---

## 🚦 Device Lifecycle Status

Devices can exist in the following states:

| Constant                    | Description       |
|----------------------------|-------------------|
| `DEVICE_STATUS_MANUFACTURED` (`u1`) | Device has been manufactured |
| `DEVICE_STATUS_TESTING` (`u2`)      | Device is undergoing testing |
| `DEVICE_STATUS_DEPLOYED` (`u3`)     | Device is deployed in the field |
| `DEVICE_STATUS_MAINTAINED` (`u4`)   | Device is in maintenance mode |

---

## 🏷 Certification Types

The following certification types are supported:

| Constant           | Description         |
|--------------------|---------------------|
| `CERT_TYPE_FDA` (`u1`)     | FDA (U.S. regulatory body) |
| `CERT_TYPE_CE` (`u2`)      | CE Marking (European standard) |
| `CERT_TYPE_ISO` (`u3`)     | ISO Certification |
| `CERT_TYPE_SAFETY` (`u4`)  | General Safety Certification |

---

## 🧾 Data Structures

### 📌 Device Details

Stored in `device-details` map:
```clarity
{
  owner: principal,
  current-status: uint,
  history: (list 10 {status: uint, timestamp: uint})
}
```

### 🛡 Certification Details

Stored in `device-certifications` map:
```clarity
{
  issuer: principal,
  timestamp: uint,
  valid: bool
}
```

---

## 📚 Public Functions

### ✅ `register-device (device-id uint, initial-status uint)`
Registers a new medical device.

- Must be initiated by contract owner or anyone (if `initial-status` is `MANUFACTURED`).
- Fails if device ID or status is invalid.

### 🔄 `update-device-status (device-id uint, new-status uint)`
Updates the status of a registered device.

- Allowed by the device owner or contract owner.

### 🔏 `add-regulatory-body (authority principal, cert-type uint)`
Adds a new approved regulatory body for a certification type.

- Only callable by contract owner.

### 🧪 `add-certification (device-id uint, cert-type uint)`
Adds a certification to a device.

- Must be an approved regulatory authority for the given cert-type.
- Cannot add if already certified.

### ❌ `revoke-certification (device-id uint, cert-type uint)`
Revokes an existing certification.

- Only issuer or contract owner can revoke.

---

## 🔍 Read-only Functions

### 🔍 `get-device-history (device-id uint)`
Returns the list of previous status changes (up to 10 entries).

### 🔍 `get-device-status (device-id uint)`
Returns the current status of the device.

### 🔍 `verify-certification (device-id uint, cert-type uint)`
Returns `true` if the certification exists and is valid.

### 🔍 `get-certification-details (device-id uint, cert-type uint)`
Returns full certification details or `none`.

---

## 🔐 Access Control

- **Contract Owner** (`contract-owner`): Has full administrative privileges.
- **Device Owner**: Has permission to update their device’s status.
- **Regulatory Authority**: Can issue certifications if approved.

---

## ⚠️ Error Codes

| Constant                   | Code | Description                          |
|---------------------------|------|--------------------------------------|
| `ERR_UNAUTHORIZED`        | `err u1` | Action not allowed by caller       |
| `ERR_INVALID_DEVICE`      | `err u2` | Device ID is invalid                |
| `ERR_STATUS_UPDATE_FAILED`| `err u3` | Failed to update device status      |
| `ERR_INVALID_STATUS`      | `err u4` | Status value is invalid             |
| `ERR_INVALID_CERTIFICATION` | `err u5` | Cert type is invalid              |
| `ERR_CERTIFICATION_EXISTS` | `err u6` | Cert already exists for the device |

---

## 🔧 Internal Utilities

- `get-current-timestamp`: Increments and returns the internal timestamp counter.
- `is-valid-status`: Ensures the status is one of the defined constants.
- `is-valid-certification-type`: Validates certification type.
- `is-valid-device-id`: Ensures device ID is within range.
- `is-contract-owner`: Checks if sender is the contract owner.
- `is-regulatory-body`: Verifies if the sender is approved for cert-type.

---

## ⏳ Timestamp Management

The contract uses an internal `timestamp-counter` to simulate timestamps in the absence of a native block timestamp in Clarity.

---

## 🧪 Testing Suggestions

When writing tests, cover:
- Registering valid/invalid devices.
- Unauthorized status updates.
- Adding/removing certifications.
- Certification verification logic.
- Handling of status history limits (max 10 entries).
- Adding multiple certifications to the same device.

---

## 📈 Potential Extensions

- Emit events for status updates and certification changes.
- Support for metadata on devices (e.g., serial number, model).
- Integration with external data via Oracles.
- Certification expiration or renewal logic.

---

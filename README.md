# RFC-draft-AuthCodeSEC
## Summary

Today, the main way domain names transfer between users or registrars
is using a mechanism called "AuthCode". This RFC proposes an upgrade to
the current AuthCode, leveraging public key cryptography, including
a schema of payload signing designed to be fully backward compatible
with the existing AuthCode in EPP (RFC 5730) while leaving room for future
extensions. This RFC also explores a 4-phased incremental approach to
replace AuthCode.

## Background

AuthCode was introduced in EPP (RFC 5730), in which it says:

```
Objects eligible for transfer MUST have associated authorization
information that MUST be provided to complete a <transfer> command.
The type of authorization information required is object-specific;
passwords or more complex mechanisms based on public key cryptography
are typical.
```

In practice, public key cryptography is rarely used in today's EPP
practices. Instead, a plaintext secret string is being used.

For example, one of the most used EPP software is provided by
CentralNic, called "RSP". It uses a plaintext string as the AuthCode. The
AuthCode is stored in the database of the registrar, and when a user
wants to transfer a domain, the user logs in to the registrar's website
to get the AuthCode, and then gives it to the gaining registrar. The
gaining registrar then sends the AuthCode to the TLD registry, and the
TLD registry then sends the AuthCode to the losing registrar (via
message queue, poll, or other ways). The losing registrar then
validates the AuthCode and then releases the domain to the gaining
registrar.

TODO: add workflow diagram

Here is a common use case: a registrant wants to hand over a domain
to another registrant. For the sake of discussion, let's call the
losing registrant Larry and the gaining registrant George, and Larry
uses a registrar called "Lovely Registrar", and the registrar George
uses is called "Great Registrar".

The problem with this process is that the AuthCode is a plaintext string:
- Its validation is only via Lovely Registrar matching the string
  with its own knowledge; no one other than Lovely Registrar could
  validate it. Not any party of the transaction, Larry or George, Great
  Registrar or TLD Registry, nor anyone else.
- It assumes the whole transmission of AuthCode, across multiple
  parties, is without leaking or eavesdropping.
- In many cases today, such AuthCodes are not being updated for a long
  time or never expire, leaving the system even more vulnerable to
  leaks or eavesdropping. Neither RFC 5730 nor any follow-up RFC
  specified a way to force reset AuthCode.

Due to these issues, the internet domain name system suffers from
AuthCode stealing or disputes.

## Specification

### Overview

We hereby propose the following mechanism:

- Use public key cryptography to use an authentication signature as
  AuthCode.
- We suggest the default algorithm as `secp256r1`, but it can support
  other signing algorithms or accept multiple signatures or aggregate
  signatures.
- We suggest the schema to be signed as the payload being the `EPP object`
  in the EPP communication, and a normalization scheme.
- We suggest including expiration time and nonce. We suggest a deny-
  list approach for early rejection.

### Details

TODO: add schema of payload to sign

TODO: add a way to establish or update public keys, such as depend on
DNSSEC.

TODO: add how the payload is represented in EPP object

TODO: add how to validate the signature using the public key

## Discussion

### Backward Compatibility

The main design goal is to allow the upgrade to be done incrementally
at each registrar without breaking the existing workflow.

For example, assuming in a transaction of a transfer of domain, the
losing registrar has already upgraded to the new mechanism, instead
of storing the AuthCode in the database and comparing it, it can validate
the AuthCode directly itself. And if the gaining registrar has not been
upgraded to be aware of this new spec, they won't be able to validate
the AuthCode on the spot, but as long as they collect the AuthCode,
they can still process the AuthCode in the same manner.

### Forward Compatibility

The main forward design compatibility is in the event a distributed
public ledger is involved, such as a smart contract is being used. They
can be configured to validate the signature of this transfer and update
the holdings of the account automatically without trusting a third party to
vouch for the transfer.

TODO: add sample code to validate the signature in the Solidity language

## Naming

The way to introduce AuthCode is similar to how DNSESC was rolled out without
breaking DNS, hence we call it AuthCodeSEC.

### Roadmap

Inspired by how banks' payment networks rolled out chips, we imagine there
can be a 4-phase rollout to support this proposal, such as each phase
to be 3-5 years:
- Phase 1: Registrars who implement the AuthCode can provide
  benefits of instant validation and validate by anyone without
  connection.
- Phase 2: When the losing registrar implemented it, it reduces the cost
  to pay for insurance or dispute to half. The other side shares half
  of the dispute cost.
- Phase 3: When the losing registrar implemented it, it is excused from
  paying for the dispute, the gaining side pays, and users are getting
  a warning.
- Phase 4: Without implementing AuthCodeSEC jeopardizes breaking
  the workflow or user experience of its users.

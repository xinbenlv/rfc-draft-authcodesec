Internet Engineering Task Force (IETF)                Zainan (Victor) Zhou
Internet-Draft                                                      Namefi
Intended status: Standards Track                              October 2024
Expires: April 30, 2025


     Domain Transfer Authorization Using Cryptographic Signatures
                   draft-authcodesec-00

Abstract

  This document specifies a mechanism to enhance domain transfer security by 
  transitioning from a shared-secret authorization model to a cryptographic 
  signature-based validation system that enables authorization based on PKIs
  (Public Key Identification) and hands over control of the domain to a
  specific next controller identified by their PKI. The process is designed
  to be fully backward compatible with existing EPP systems through staged 
  incremental upgrades.

Status of This Memo

  This Internet-Draft is submitted in full conformance with the
  provisions of BCP 78 and BCP 79.

  Internet-Drafts are working documents of the Internet Engineering Task
  Force (IETF).  Note that other groups may also distribute working
  documents as Internet-Drafts.  The list of current Internet-Drafts is
  at https://datatracker.ietf.org/drafts/current/.

  Internet-Drafts are draft documents valid for a maximum of six months
  and may be updated, replaced, or obsoleted by other documents at any
  time.  It is inappropriate to use Internet-Drafts as reference
  material or to cite them other than as "work in progress."

  This Internet-Draft will expire on April 27, 2025.

Copyright Notice

  Copyright (c) 2024 IETF Trust and the persons identified as the
  document authors.  All rights reserved.

  This document is subject to BCP 78 and the IETF Trust's Legal
  Provisions Relating to IETF Documents
  (https://trustee.ietf.org/license-info) in effect on the date of
  publication of this document.  Please review these documents
  carefully, as they describe your rights and restrictions with respect
  to this document.

Table of Contents

   1. Status of This Memo ..................................... TBD
   2. Introduction ........................................... TBD
      2.1. Description of the Current Process ................ TBD
   3. Protocol Elements and Mechanisms ....................... TBD
      3.1. EPP Extension Overview ............................ TBD
      3.2. Enhanced Authorization Information Format .......... TBD
      3.3. Digest Generation ................................ TBD
      3.4. Signature Generation ............................. TBD
      3.5. Format in EPP Extension Element .................. TBD
           3.5.1. Required Fields ........................... TBD
           3.5.2. XML Schema Definition ..................... TBD
   4. Verification Flow .................................... TBD
      4.1. Verification Models Overview ....................... TBD
      4.2. Losing Side Authorization Models ................ TBD
      4.3. Gaining Side Authorization Models ................ TBD
   5. Security Considerations ............................... TBD
   6. Draft Notes: Unresolved Feedbacks and Design Questions. TBD
      6.1. Threat Analysis ................................. TBD
           6.1.6.1. Cross-Registrant Misuse ................ TBD
           6.1.6.2. Double-Selling Protection ............... TBD
           6.1.6.3. Audit Trail Limitations ................ TBD
      6.2. Choosing between pwAuthInfo and extAuthInfo ...... TBD
   7. References ........................................... TBD
      7.1. RFCs ........................................... TBD
      7.2. Other Documents ................................. TBD

1. Status of This Memo

  (TODO: add status of this memo)

2. Introduction

This document specifies a mechanism to enhance domain transfer security by 
transitioning from a shared-secret authorization model to a cryptographic 
signature-based validation system that enable authorization based on PKIs
(Public Key Identification) and hand over the control of the domain to
specific next controller identified by their PKI. The process is designed to
be fully backward compatible with existing EPP systems with staged incremental
upgrades inspired by the DNSSEC, HTTPS, and Credit Card Chip migration.

The current transfer process relies on the presentation of an 
authentication code (authcode) by the gaining registrar as proof of 
transfer authority. 

This specification defines an extended authorization information format
that incorporates cryptographic signatures, enabling registries to validate 
multiple aspects of the transfer request:

  * that it originates from the legitimate domain registrant
  * that it contains the correct receiving registrant information
  * that it includes proper approval signature or signatures from
    designated parties when required (such as administrative contacts 
    or other stakeholders)

To ensure smooth transition and maintain interoperability with existing 
systems, this specification includes backward compatibility mechanisms 
allowing registries and registrars to support both the legacy authcode 
format and the new signature-based format simultaneously. 

The specification provides guidance for gradual migration while 
maintaining existing transfer workflows, enabling deployments without 
requiring synchronized updates across all participants in the domain 
registration ecosystem.

2.1 Description of the Current Process

The current EPP transfer request process defined in RFC-5730 involves
the following sequence:

2.1.1. The losing registrar sets or updates the authInfo for a domain
      object through an EPP <update> command to the registry. The
      registry MUST store this authInfo value in its database.

2.1.2. The losing registrar provides this authInfo code to the current
      registrant. The method of this transmission is out of scope of
      the EPP protocol.

2.1.3. The current registrant provides this authInfo code to the
      gaining registrar. This transmission method is also out of scope
      of the EPP protocol.

2.1.4. The gaining registrar submits a transfer request to the registry
      through EPP <transfer> command, which MUST include this authInfo
      in the request.

2.1.5. The registry MUST validate that the provided authInfo matches
      the one stored in the registry database for this domain.

2.1.6. Upon successful validation, the registry MUST notify both
      registrars, update the domain object status to "pendingTransfer",
      and MUST change the authInfo to a new value known only to the
      registry.

This validation mechanism relies solely on the matching of a shared
secret between parties, which presents several security limitations
that this specification aims to address. The fact that the authInfo
must be transmitted between multiple parties out-of-band increases the
risk of compromise.

2.2. Threat Model

The extension intends to address the following advanced security issues
in the context of authInfo-based domain transfer mechanism:

* Man-in-the-Middle Attacks during out-of-band transmission
* Insider Threats from registrar employees and support staff
* Lack of Transfer Intent Binding
* Revocation Management Issues
* Replay Attacks, including:
  - No temporal validity constraints
  - Multiple use vulnerability
  - Lack of transfer context binding
  - Missing nonce protection
* Cross-Registrant Vulnerabilities:
  - AuthInfo leakage and reuse
  - Double-selling risks
  - Insufficient audit trails

2.3. Extensibility Assumptions

This specification builds upon several extensibility aspects of
RFC-5730 (EPP):

2.3.1. AuthInfo Structure Extensibility

    According to RFC-5730 Section 2.7.1, EPP provides an extension
    framework that allows for definition of both new protocol 
    operations and object extensions:

    * The <extension> element MUST contain up to one instance of any 
      object extension elements
    * Any object extension element MAY extend any object element, 
      including the <authInfo> element
    * Extension elements MUST be qualified by a XML namespace
      declaration

    This extensibility mechanism allows for the enhancement of the
    authInfo structure while maintaining backward compatibility.

2.3.2. Password Element Size

    After reviewing RFC-5730, it's worth noting that the specification
    does not explicitly define size limitations for the domain:pw
    element. In current practice most authcodes are 6-8 characters long.
    but transitioning to a signature-based system will require a longer
    authcode.

2.3.3. Verification Assumptions

    The following verification behavior is defined in RFC-5730 
    Section 2.9.3.4:

    * The server MUST validate the authorization information provided
      when a <transfer> command is processed
    * The server MAY reject requests that contain authorization
      information that has aged beyond a server-specific date or time

    This existing verification requirement provides the foundation
    for extending the validation process to include cryptographic
    signature verification.

2.3.4. Implementation Considerations

    Given the extensibility mechanisms provided by RFC-5730 and the
    lack of explicit size constraints:

    * This specification MUST use proper XML namespace declarations
      for all new elements
    * New elements MUST be added within the <extension> framework
    * Implementations MUST maintain compatibility with existing
      authInfo processing
    * Size limitations MUST be specified for all new elements
    * The extension SHOULD allow for future cryptographic algorithm
      updates

3. Protocol Description

This section defines the protocol elements and mechanisms for the new
cryptographic signature-based domain transfer authorization system.

3.1. EPP Extension Overview

    The protocol leverages EPP extensions to convey the enhanced
    authorization information, including the authorization information,
    cryptographic digest, and associated signatures. These extensions
    augment existing EPP transfer request operations.

3.2. Enhanced Authorization Information Format

    The enhanced authorization information format includes:
      * The approver's PKI
      * The approver's authority type: registrant, registrar (and it 
        can be extended to allow other types of authorities such as 
        law enforcement or judicial bodies)
      * Anti-replay protection mechanisms (e.g., expiration timestamp,
        nonce)
      * Additional authorization parameters

    The authorization information is encoded in XML format as an EPP
    extension element.

3.3. Digest Generation

    The protocol defines standardized steps and methods for generating
    cryptographic digests from the authorization information. This
    includes:
      * Specification of supported hash algorithms
      * Canonicalization of input data
      * Digest computation procedure

3.4. Signature Generation

    The protocol specifies the process for generating cryptographic
    signatures, including:
      * Supported signature algorithms
      * Key requirements and formats
      * Signature computation procedure using the registrant's key

3.5 Format in EPP Extension Element

    The enhanced authorization information is encoded in XML format as an
    EPP extension element as followed

3.5.1 Required Fields

    The enhanced authorization information consists of the following required fields:

    * version - Schema version number
    * domainName - The domain name being transferred
    * nonce - Incremental number to prevent replay attacks
    * receiverInfo - Container for receiver details:
      * receiverType: Type of receiving entity (registrant/registrar)
      * receiverKey: PKI of the receiver
      * receiverIdentifier: Unique identifier of the receiver
    * approverInfo - Container for approver details:
      * approverType: Type of approving entity (registrant/registrar)
      * approverKey: PKI of the approver
      * approverIdentifier: Unique identifier of the approver
    * digestInfo - Container for digest details:
      * digestAlgorithm: Hash algorithm used
      * digestValue: Hexadecimal representation of the computed digest

3.5.2 XML Schema Definition

BEGIN
<?xml version="1.0" encoding="UTF-8"?>
<schema targetNamespace="urn:ietf:params:xml:ns:epp:authcodesec-1.0"
        xmlns:authcodesec="urn:ietf:params:xml:ns:epp:authcodesec-1.0"
        xmlns:epp="urn:ietf:params:xml:ns:epp-1.0"
        xmlns:eppcom="urn:ietf:params:xml:ns:eppcom-1.0"
        xmlns="http://www.w3.org/2001/XMLSchema"
        elementFormDefault="qualified">

  <import namespace="urn:ietf:params:xml:ns:eppcom-1.0"/>
  <import namespace="urn:ietf:params:xml:ns:epp-1.0"/>

  <annotation>
    <documentation>
      Extension to EPP extAuthInfoType for secure domain transfers
    </documentation>
  </annotation>

  <element name="secData" type="authcodesec:secDataType" 
  substitutionGroup="eppcom:extAuthInfo"/>

  <complexType name="secDataType">
    <complexContent>
      <extension base="eppcom:extAuthInfoType">
        <sequence>
          <element name="version" type="token" fixed="1.0"/>
          <element name="domainName" type="eppcom:labelType"/>
          <element name="nonce" type="token"/>
          <element name="receiverInfo" type="authcodesec:entityInfoType"/>
          <element name="approverInfo" type="authcodesec:entityInfoType"/>
          <element name="digestInfo" type="authcodesec:digestInfoType"/>
        </sequence>
      </extension>
    </complexContent>
  </complexType>

  <complexType name="entityInfoType">
    <sequence>
      <element name="type" type="authcodesec:entityTypeEnum"/>
      <element name="key" type="base64Binary"/>
      <element name="identifier" type="token"/>
    </sequence>
  </complexType>

  <simpleType name="entityTypeEnum">
    <restriction base="token">
      <enumeration value="registrant"/>
      <enumeration value="registrar"/>
      ... TODO add other types of authorities such as
      <enumeration value="lawEnforcement"/>
    </restriction>
  </simpleType>

  <complexType name="digestInfoType">
    <sequence>
      <element name="algorithm" type="authcodesec:digestAlgorithmEnum"/>
      <element name="value" type="hexBinary"/>
    </sequence>
  </complexType>

  <simpleType name="digestAlgorithmEnum">
    <restriction base="token">
      ... TODO: add supported algorithms / standard to define digesting
    </restriction>
  </simpleType>

</schema>
END

3.5.3. Signature in domain:pw

The signature value in domain:pw is the Base64-encoded value of the signature computed over the digest:

C:        <domain:authInfo>
C:          <domain:pw>Base64EncodedSignatureValueComputedOverTheDigest...</domain:pw>
C:        </domain:authInfo>

3.5.4 Example Usage

Example of a domain transfer request with enhanced authorization information:

C:<?xml version="1.0" encoding="UTF-8" standalone="no"?>
C:<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
C:  <command>
C:    <transfer op="request">
C:      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
C:        <domain:name>example.com</domain:name>
C:        <domain:authInfo>
C:          <domain:pw>Base64EncodedSignatureValueComputedOverTheDigest...</domain:pw>
C:        </domain:authInfo>
C:      </domain:transfer>
C:    </transfer>
C:    <extension>
C:      <authcodesec:secData 
C:       xmlns:authcodesec="urn:ietf:params:xml:ns:epp:authcodesec-1.0">
C:        <authcodesec:version>1.0</authcodesec:version>
C:        <authcodesec:domainName>example.com</authcodesec:domainName>
C:        <authcodesec:nonce>f7027456abc8903d</authcodesec:nonce>
C:        <authcodesec:receiverInfo>
C:          <authcodesec:type>registrant</authcodesec:type>
C:          <authcodesec:key>MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...</authcodesec:key>
C:          <authcodesec:identifier>RECV-12345</authcodesec:identifier>
C:        </authcodesec:receiverInfo>
C:        <authcodesec:approverInfo>
C:          <authcodesec:type>registrant</authcodesec:type>
C:          <authcodesec:key>MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...</authcodesec:key>
C:          <authcodesec:identifier>APPR-67890</authcodesec:identifier>
C:        </authcodesec:approverInfo>
C:        <authcodesec:digestInfo>
C:          <authcodesec:algorithm>sha256</authcodesec:algorithm>
C:          <authcodesec:value>2CF24DBA5FB0A30E26E83B2AC5B9E29E1B161E5C1FA7425E73043362938B9824</authcodesec:value>
C:        </authcodesec:digestInfo>
C:      </authcodesec:secData>
C:    </extension>
C:    <clTRID>ABC-12345</clTRID>
C:  </command>
C:</epp>


4. Verification Flow

The protocol specifies the process for verifying cryptographic
signatures, including:

  * Signature verification procedure using the registrant's key
  * Verification of anti-replay protection mechanisms
  * Verification of additional authorization parameters

This specification defines three models of transfer verification to
ensure smooth transition from traditional authInfo to the new
cryptographic signature-based system.

4.1. Verification Models Overview

    The verification process consists of two components: the losing
    side authorization and the gaining side verification. Each
    component can operate in one of three models, allowing for
    staged migration:

    +----------------+------------------------------------------+
    | Model          | Description                              |
    +----------------+------------------------------------------+
    | Model A        | Full cryptographic model with registrant |
    |               | signatures and keys                       |
    | Model B        | Semi-cryptographic model with registrar  |
    |               | signatures and keys                       |
    | Model C        | Traditional authInfo model               |
    +----------------+------------------------------------------+
  
  The three models are designed to allow for staged migration from the
  current authInfo-based mechanism to the new cryptographic signature-based
  mechanism.

  Model A is the strongest and most secure model, but also requires the
  most significant changes to existing workflows. Model C is the weakest
  and least secure model, but also requires the least changes to existing
  workflows.

  Any party, registrant, registrar or registry can start by supporting
  Model C and then move to Model B or Model A as needed.

  Any party can add their support for Model A or Model B at any time, 
  when transfer counter party doesn't support the same model, the transfer
  can still be completed by falling back to a lower model, as described 
  in section 4.4.

4.2. Model A. Full Cryptographic Model

4.2.1 Request to update the PKI

* Any current registrant can request its current registrar to update its 
  registrant information with the enhanced authorization information including 
  the PKI.
  * If such the current registrant already is registered with 
    a PKI, such request MUST include a crypography signature to prove
    the ownership of the PKI and apporval of the update request.
    Otherwise, the registrar MUST validate the authenticity of the  
  
  (TODO: define the update flow and EPP command)

  * And then the current registrar MUST submit a transfer request to the registry
    with the enhanced authorization information to trigger the transfer
    process. Assuming the registry supports Model A, the transfer request
    MUST be rejected if the enhanced authorization information is missing,
    the signature is invalid, or the PKI is not updated.
  
  (TODO: define the error codes and error messages)

4.2.2. Request to update the AuthInfo (optional)

This step can be skipped if all parties in the transfer chain support Model A.
But for backward compatibility, the current authInfo-based mechanism can be
used as a fallback.

The current registrant can authorize a transfer of domain by signing the
enhanced authorization information demonstrated in section 3.5.4. by 
cryptographic signing with its PKI.

(TODO: define an example of payload to be signed and digesting algorithm)

The signature value denoted as `sig` will be placed in the domain:pw element
as defined in section 3.5.3.

The current registrant will then submit a transfer request to the registrar,
and the registrar will submit a transfer request to the registry.

The registry will verify the signature of the current registrant using the PKI
and the enhanced authorization information, and it will save the signature
value in the registry database for future reference.

4.2.3. The gaining registrar will submit a transfer request to the registry

Supposedly the gaining registrar supports Model A, the gaining registrant 
(it could be the same as the current registrant or someone who bought the
domain from the current registrant) will submit a transfer request to the
registry with the enhanced authorization information.

The gaining registrar will first verify the signature of the gaining
registrant using the PKI and the enhanced authorization information, and
then it will submit a transfer request to the registry with the enhanced
authorization information.

The registry will verify the signature of the gaining registrant using the PKI
and the enhanced authorization information, if the signature is valid, the
registry will complete the transfer process by updating the domain new owner
to the gaining registrant, including the PKI.

(TODO: define example EPP command, and define the error codes and error
messages)

4.3. Fallback based on support of PKI

If the registry doesn't support PKI, the transfer process will fallback to
Model C.

Else if any of the registrars doesn't support PKI, the transfer process will
fallback to Model C.

Else if both registrars support PKI, the transfer process will fallback to
Model B.

But even if registry doesn't support PKI, if both registrars support PKI, 
the authcode can be verified using PKI which is stronger than merely Model C.

This incremental upgrade mechanism enables each individual registrar
to benefit from adding the PKI support without waiting for the other
registrar to add support, similar to the approach of DNSSEC, HTTPS deployment
and bank credit card chips rollout.

5. Security Considerations
  
  TODO: limitation due to lack of finalization of decentralized ledgers.
  

6. Draft Notes

6.1. Description of Threat Model

  The RFC aims at addressing the following advanced threat models:

6.1.1. Man-in-the-Middle Attacks

    Since the authInfo transmission between registrant and registrars
    occurs out-of-band and often through insecure channels (e.g., 
    email, control panel screenshots, support tickets):
      * The authInfo can be intercepted during transmission
      * There is no cryptographic binding between the authInfo and 
        the intended receiving registrant
      * A malicious actor can initiate an unauthorized transfer using
        an intercepted authInfo

6.1.2. Insider Threats

    The shared-secret nature of authInfo creates vulnerabilities to
    insider threats:
      * Any employee at the losing registrar with access to the
        control panel can view or extract authInfo values
      * Support staff handling customer requests can potentially
        misuse authInfo codes they've accessed
      * There is no cryptographic proof that the actual domain
        registrant initiated or approved the transfer

6.1.3. No Binding to Transfer Intent

    The authInfo serves only as a shared secret without any binding to:
      * The identity of the intended receiving registrant
      * The intended timing of the transfer
      * Additional authorization requirements (e.g., corporate domain
        transfers requiring multiple approvals)
      * The specific transfer request itself, allowing replay attacks

6.1.4. Revocation Challenges

    Once an authInfo has been compromised:
      * There is no standardized mechanism to revoke it without
        performing a domain update
      * The registrant may not realize the compromise until after
        an unauthorized transfer occurs
      * The registry cannot distinguish between legitimate and
        unauthorized uses of a valid authInfo

6.1.5. Replay Attacks

The current authInfo-based mechanism lacks several essential
protections against replay attacks:

6.1.5.1. Temporal Validity

  * The authInfo has no built-in expiration mechanism
  * Once generated, it remains valid until explicitly changed
  * A captured authInfo can be used at any future time until the
    losing registrar or registrant updates it
  * There is no standard way to limit the validity period of an
    authInfo

6.1.5.2. Multiple Use

  * The same authInfo can be used multiple times for different
    transfer attempts
  * A malicious actor can:
      - Capture a valid authInfo during a legitimate transfer
      - Store it for future unauthorized transfers
      - Use it again after the domain returns to the original
        registrar
  * The registry cannot distinguish between the original intended
    use and subsequent replay attempts

6.1.5.3. Transfer Context

  * The authInfo is not bound to any specific transfer context
  * The same code can be used to initiate transfers:
      - To different gaining registrars
      - At different times
      - With different receiving registrant details
  * There is no cryptographic binding between the authInfo and the
    intended transfer parameters

6.1.5.4. No Nonce Protection

  * The protocol lacks a nonce or similar mechanism to ensure
    uniqueness of each transfer request
  * Transfer requests cannot be uniquely identified or tracked
  * Makes it impossible to implement replay detection at the
    protocol level

6.1.6. Cross-Registrant Vulnerabilities within Same Registrar

The current authInfo mechanism lacks isolation between different
registrants at the same registrar:

6.1.6.1. Leaked AuthInfo Reuse

  * A registrar employee or system with access to multiple
    registrants' authInfo could:
      - Extract authInfo from one registrant's domain
      - Use it for transfers of another registrant's domain
  * The registry cannot detect this cross-registrant misuse as
    the authInfo format and validation is identical
  * No cryptographic binding exists between the authInfo and
    the specific registrant identity

6.1.6.2. Double-Selling Protection

  * A malicious registrar could:
      - Generate valid authInfo for the same domain
      - Provide them to different potential buyers
      - Allow multiple transfer attempts using different authInfo
  * The current mechanism cannot prevent or detect:
      - Multiple valid authInfo existing simultaneously
      - Which registrant was the legitimate intended transferee
      - Whether the authInfo was generated with proper
        authorization

6.1.6.3. Audit Trail Limitations

  * No cryptographic proof of:
      - Which registrant authorized the authInfo generation
      - When the authorization was granted
      - The intended receiving registrant
  * Makes dispute resolution difficult in cases of:
      - Unauthorized cross-registrant transfers
      - Double-selling incidents
      - Employee misconduct

6.2. Unresolved Quesiton: How to choose between pwAuthInfo and extAuthInfo?

Scott says in 

> Having said that, I designed EPP in a way that allows for specification of
> other approaches. Section 4.2 of RFC 5730 includes the schema that defines
> authorization information. Note the “pwAuthInfoType” and the
> "extAuthInfoType" type definitions. "extAuthInfoType" can be used as a
> “hook” to define a new type. Given that the capability exists, I’d suggest
> that you send a note to the IETF REGEXT working group mailing list asking
> if anyone is interested in the possibility of defining an extension for a
> new PKI-based authorization information type. You’d be better of measuring
> people’s interest in the topic before you invest a lot of time working on a
> proposal.
> -- S. Hollenbeck, 2024-03-19 https://mailarchive.ietf.org/arch/msg/regext/pRSTKwvDRM4WM_s-nme2PRig4Z4/

In practice it domain:ext has not been widely used. And since we want to 
maintain backward compatibility with existing systems. The author of 
this document propose that we should choose pwAuthInfo over extAuthInfo for
better backward compatibility.

7. References

7.1. RFCs
    * RFC 1034 by P. Mockapetris
    * RFC 1035 by P. Mockapetris
    * RFC 5730 by S. Hollenbeck
    * RFC 5731 by S. Hollenbeck
    * RFC 5732 by S. Hollenbeck
    * RFC 7451 by S. Hollenbeck
    * RFC 7848 by G. Lozano
    * RFC 8334 by J. Gould, W. Tan, G. Brown
    * RFC 8807 by J. Gould, M. Pozun
    * RFC 9095 by J. Yao, L. Zhou, H. Li, N. Kong, J. Xie
    * RFC 9154 by J. Gould, R. Wilhelm
    * draft-ietf-regext-verificationcode-06 by J. Gould, R. Wilhelm, 

7.2. Other Documents
- Presentation: Transfer Authcodes at .se and .nu by Eric Skoglund (Apr 2024)
- Discussion: [\[regext\]Fwd: Idea about AuthCodeSEC: use PKI Cryptography for AuthCode](https://mailarchive.ietf.org/arch/msg/regext/WPNywS9VAFhE3sJTRn9cR7FcRA4/)
(TODO: add other documents)

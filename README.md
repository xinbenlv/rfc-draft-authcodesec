Internet Engineering Task Force (IETF)                Zainan (Victor) Zhou
Internet-Draft                                                      Namefi
Intended status: Standards Track                              October 2024
Expires: April 30, 2025


     Domain Transfer Authorization Using Cryptographic Signatures
                   draft-authcodesec-00

Abstract

  This document defines a new standard for domain transfer authorization
  that replaces the traditional shared-secret authcode with a 
  cryptographic signature-based system. This enhancement provides stronger
  authentication and authorization mechanisms for domain transfers while
  maintaining backward compatibility with existing systems.

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

  (TODO: add table of contents)

1. Status of This Memo

  (TODO: add status of this memo)

2. Introduction

This document specifies a mechanism to enhance domain transfer security by 
transitioning from a shared-secret authorization model to a cryptographic 
signature-based validation system. 

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

  The current authInfo-based domain transfer mechanism is vulnerable to
  several types of attacks and security issues:

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
     authorization information, including the authorization token,
     cryptographic digest, and associated signatures. These extensions
     augment existing EPP transfer request operations.

  3.2. Enhanced Authorization Information Format

     The enhanced authorization information format includes:
        * The approver's public key
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
     EPP extension element.

  3.5.1 Required Fields

     The enhanced authorization token consists of the following required fields:

     * version - Schema version number
     * tokenId - Unique identifier for this authorization token
     * domainName - The domain name being transferred
     * issueTime - Token issuance timestamp
     * expiryTime - Token expiration timestamp
     * nonce - Random value to prevent replay attacks
     * gainingRegistrantId - Identifier of intended receiving registrant
     * approverInfo - Container for approver details:
       * approverType: Type of approving entity (registrant/registrar)
       * approverKey: Public key of the approver
       * approverIdentifier: Unique identifier of the approver
     * signature - Cryptographic signature covering the above fields

  3.5.2 XML Schema Definition

<?xml version="1.0" encoding="UTF-8"?>
<schema xmlns="http://www.w3.org/2001/XMLSchema"
        xmlns:authcodesec="urn:ietf:params:xml:ns:authcodesec-1.0"
        targetNamespace="urn:ietf:params:xml:ns:authcodesec-1.0"
        elementFormDefault="qualified">

  <element name="authInfo" type="authcodesec:authInfoType"/>
  
  <complexType name="authInfoType">
    <sequence>
      <element name="version" type="string" fixed="1.0"/>
      <element name="tokenId" type="string"/>
      <element name="domainName" type="eppcom:labelType"/>
      <element name="issueTime" type="dateTime"/>
      <element name="expiryTime" type="dateTime"/>
      <element name="nonce" type="base64Binary"/>
      <element name="gainingRegistrantId" type="string"/>
      <element name="approverInfo" type="authcodesec:approverInfoType"/>
      <element name="signature" type="base64Binary"/>
    </sequence>
  </complexType>

  <complexType name="approverInfoType">
    <sequence>
      <element name="approverType">
        <simpleType>
          <restriction base="string">
            <enumeration value="registrant"/>
            <enumeration value="registrar"/>
          </restriction>
        </simpleType>
      </element>
      <element name="approverKey" type="base64Binary"/>
      <element name="approverIdentifier" type="string"/>
    </sequence>
  </complexType>
</schema>


3.5.3 Example Usage

A complete authorization token in an EPP transfer request would look like:

<?xml version="1.0" encoding="UTF-8"?>
<epp xmlns="urn:ietf:params:xml:ns:epp-1.0">
  <command>
    <transfer op="request">
      <domain:transfer xmlns:domain="urn:ietf:params:xml:ns:domain-1.0">
        <domain:name>example.com</domain:name>
        <domain:authInfo>
          <domain:pw>SW4gdGhpcyBleGFtcGxlLCB0aGlzIGlzIG</domain:pw>
        </domain:authInfo>
      </domain:transfer>
    </transfer>
    <extension>
      <authcodesec:authInfo xmlns:authcodesec="urn:ietf:params:xml:ns:authcodesec-1.0">
        <authcodesec:version>1.0</authcodesec:version>
        <authcodesec:tokenId>tok-12345</authcodesec:tokenId>
        <authcodesec:domainName>example.com</authcodesec:domainName>
        <authcodesec:issueTime>2024-10-31T10:00:00Z</authcodesec:issueTime>
        <authcodesec:expiryTime>2024-11-30T10:00:00Z</authcodesec:expiryTime>
        <authcodesec:nonce>dGhpcyBpcyBhIHRlc3Qgbm9uY2U=</authcodesec:nonce>
        <authcodesec:gainingRegistrantId>REG-89012</authcodesec:gainingRegistrantId>
        <authcodesec:approverInfo>
          <authcodesec:approverType>registrant</authcodesec:approverType>
          <authcodesec:approverKey>MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A...</authcodesec:approverKey>
          <authcodesec:approverIdentifier>REG-67890</authcodesec:approverIdentifier>
        </authcodesec:approverInfo>
        <authcodesec:signature>SW4gdGhpcyBleGFtcGxlLCB0aGlzIGlzIG...</authcodesec:signature>
      </authcodesec:authInfo>
    </extension>
    <clTRID>ABC-12345</clTRID>
  </command>
</epp>
  
4. Signature Verification

     The protocol specifies the process for verifying cryptographic
     signatures, including:
        * Signature verification procedure using the registrant's key
        * Verification of anti-replay protection mechanisms
        * Verification of additional authorization parameters


60. Backward Compatibility

   This specification defines three models of transfer verification to
   ensure smooth transition from traditional authInfo to the new
   cryptographic signature-based system.

   60.1. Verification Models Overview

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

   60.2. Losing Side Authorization Models

        60.2.1. Model A: Registrant Signature Model

           * Losing registrant generates signature using their private key
           * Requires registrant to maintain their key pair
           * Provides strongest security and non-repudiation
           * Requires most significant changes to existing workflows

        60.2.2. Model B: Registrar Signature Model

           * Losing registrar generates signature using their private key
           * Maintains registrar's role in the authorization process
           * Provides improved security over traditional authInfo
           * Requires minimal changes to registrant experience

        60.2.3. Model C: Traditional AuthInfo Model

           * Losing registrar provides traditional authInfo
           * Maintains full backward compatibility
           * No changes to existing workflows
           * Retains current security limitations

   60.3. Gaining Side Verification Models

        60.3.1. Model A: Registrant Key Verification

           * Registry verifies signature using registrant's public key
           * Registry MUST store registrant public keys
           * Provides end-to-end security
           * Requires new key management infrastructure

        60.3.2. Model B: Registrar Key Verification

           * Registry verifies signature using registrar's public key
           * Registry MUST store registrar public keys
           * Balance of security and implementation complexity
           * Leverages existing registrar relationships

        60.3.3. Model C: Traditional AuthInfo Verification

           * Registry verifies against stored authInfo value
           * Maintains existing verification process
           * No additional infrastructure required
           * Retains current security limitations

   60.4. Migration Considerations

        Registries MUST support all models simultaneously during the
        transition period. The following combinations are valid:

        * A/A: Full cryptographic model (highest security)
        * B/B: Registrar-based cryptographic model
        * C/C: Traditional model (backward compatibility)
        * B/C: Hybrid model (signature generation, traditional verify)

        Cross-model combinations not listed above MUST NOT be supported
        to maintain security consistency.

70. Security Considerations

  (TODO: add security considerations)

80. Draft Notes

  80.1. Threat Model

    The RFC aims at addressing the following advanced threat models:

  80.1.1. Man-in-the-Middle Attacks

     Since the authInfo transmission between registrant and registrars
     occurs out-of-band and often through insecure channels (e.g., 
     email, control panel screenshots, support tickets):
        * The authInfo can be intercepted during transmission
        * There is no cryptographic binding between the authInfo and 
          the intended receiving registrant
        * A malicious actor can initiate an unauthorized transfer using
          an intercepted authInfo

  80.1.2. Insider Threats

     The shared-secret nature of authInfo creates vulnerabilities to
     insider threats:
        * Any employee at the losing registrar with access to the
          control panel can view or extract authInfo values
        * Support staff handling customer requests can potentially
          misuse authInfo codes they've accessed
        * There is no cryptographic proof that the actual domain
          registrant initiated or approved the transfer

  80.1.3. No Binding to Transfer Intent

     The authInfo serves only as a shared secret without any binding to:
        * The identity of the intended receiving registrant
        * The intended timing of the transfer
        * Additional authorization requirements (e.g., corporate domain
          transfers requiring multiple approvals)
        * The specific transfer request itself, allowing replay attacks

  80.1.4. Revocation Challenges

     Once an authInfo has been compromised:
        * There is no standardized mechanism to revoke it without
          performing a domain update
        * The registrant may not realize the compromise until after
          an unauthorized transfer occurs
        * The registry cannot distinguish between legitimate and
          unauthorized uses of a valid authInfo

  80.1.5. Replay Attacks

     The current authInfo-based mechanism lacks several essential
     protections against replay attacks:

     80.1.5.1. Temporal Validity

        * The authInfo has no built-in expiration mechanism
        * Once generated, it remains valid until explicitly changed
        * A captured authInfo can be used at any future time until the
          losing registrar or registrant updates it
        * There is no standard way to limit the validity period of an
          authInfo

     80.1.5.2. Multiple Use

        * The same authInfo can be used multiple times for different
          transfer attempts
        * A malicious actor can:
           - Capture a valid authInfo during a legitimate transfer
           - Store it for future unauthorized transfers
           - Use it again after the domain returns to the original
             registrar
        * The registry cannot distinguish between the original intended
          use and subsequent replay attempts

     80.1.5.3. Transfer Context

        * The authInfo is not bound to any specific transfer context
        * The same code can be used to initiate transfers:
           - To different gaining registrars
           - At different times
           - With different receiving registrant details
        * There is no cryptographic binding between the authInfo and the
          intended transfer parameters

     80.1.5.4. No Nonce Protection

        * The protocol lacks a nonce or similar mechanism to ensure
          uniqueness of each transfer request
        * Transfer requests cannot be uniquely identified or tracked
        * Makes it impossible to implement replay detection at the
          protocol level

    80.1.6. Cross-Registrant Vulnerabilities within Same Registrar

     The current authInfo mechanism lacks isolation between different
     registrants at the same registrar:

     80.1.6.1. Leaked AuthInfo Reuse

        * A registrar employee or system with access to multiple
          registrants' authInfo could:
           - Extract authInfo from one registrant's domain
           - Use it for transfers of another registrant's domain
        * The registry cannot detect this cross-registrant misuse as
          the authInfo format and validation is identical
        * No cryptographic binding exists between the authInfo and
          the specific registrant identity

     80.1.6.2. Double-Selling Protection

        * A malicious registrar could:
           - Generate valid authInfo for the same domain
           - Provide them to different potential buyers
           - Allow multiple transfer attempts using different authInfo
        * The current mechanism cannot prevent or detect:
           - Multiple valid authInfo existing simultaneously
           - Which registrant was the legitimate intended transferee
           - Whether the authInfo was generated with proper
             authorization

     80.1.6.3. Audit Trail Limitations

        * No cryptographic proof of:
           - Which registrant authorized the authInfo generation
           - When the authorization was granted
           - The intended receiving registrant
        * Makes dispute resolution difficult in cases of:
           - Unauthorized cross-registrant transfers
           - Double-selling incidents
           - Employee misconduct


  90. References

  90.1. RFCs
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

  90.2. Other Documents
  - Presentation: Transfer Authcodes at .se and .nu by Eric Skoglund (Apr 2024)
  - Discussion: [\[regext\]Fwd: Idea about AuthCodeSEC: use Public Key Cryptography for AuthCode](https://mailarchive.ietf.org/arch/msg/regext/WPNywS9VAFhE3sJTRn9cR7FcRA4/)
  (TODO: add other documents)

# AuthCodeSEC Draft Repository

## Current Draft

The current draft is in the `src` directory.
The draft is written in Markdown format.

To generate the XML and text versions of the draft, run the following command:
```bash
kramdown-rfc ./src/draft-zzn-authcodesec.md > ./dist/draft-zzn-authcodesec-99.xml
xml2rfc ./dist/draft-zzn-authcodesec-99.xml > ./dist/draft-zzn-authcodesec-99.txt
```

To generate the text version of the draft, run the following command:
```bash

```


## Work Journal



iv. AuthCodeSEC (Victor Zhou)

Slides:
https://datatracker.ietf.org/meeting/121/materials/slides-121-regext-ietf-121-authcodesec-slide-number-includedpdf-00

Victor reviewed the slides.

Q&A:

Andy Newton: We shouldn't reinvent other public key crpto that we can
just 'steal'. That is, there are x509 certs, we should just reuse those
as a container object.

Pawel Kowalik: Model A: If a registrant signs the object, how would a Ry
know the public key of the registrant. Victor: in the new paradigm of
blockchain usage, people are managing their own keys.

Jim Gould: domain-ext would be appropriate since this is a new mechanism
for authorization info. Victor: seems like it would be undecided.

Scott Hollenbeck: Transfer friction currently exists by design. That is
to prevent domain "slamming".

Rick Wilhelm: AuthCodes are changing to be ephemeral due to the
transfer. Not sure if this is worth the effort. Victor: in the context
of a sale, the security is still important.

Jody Kolker: Agree with Scott and Rick. Instant transfer has been pushed
back in the ICANN world several time. Model A (registrant sign) is not
practical in the real world.

### Transcription

https://app.notta.ai/7150251375583760384/folders/0/ee9b0638-0450-44f1-a2db-b1c9e390574f#teams_detail

Here's a summary of the feedback on Victor's AuthCodeSEC presentation:

Key Feedback Points:
1. Security and Friction Concerns
- Scott Holmberg and Rick Wilhelm emphasized the importance of maintaining some friction in the domain transfer process to prevent "domain slamming"
- The losing registrar must retain the ability to deny a transfer
- Current ICANN policies are already moving towards making AuthCodes more secure (ephemeral, short-lived)

2. Practical Implementation Challenges
- Jody noted most registrants cannot handle cryptographic processes
- Model A (registrant signing) would only work for:
  - Companies with large IT departments
  - Domain professionals with technical expertise
- Suggested Model B (registrar signing) might be more practical

3. Technical Considerations
- Andy Newton appreciated the general idea of using public key cryptography
- Pavel Kovalik raised key management questions
- Victor suggested future developments like passkey and single sign-on could help manage keys

4. Use Case Discussions
- Victor highlighted domain sales as a key use case where current AuthCode methods are insecure
- Jody mentioned alternative domain sale models that don't require direct AuthCode management

Overall Sentiment:
- Interesting concept but questionable whether the complexity is justified
- Recommendation to continue discussion on the mailing list
- No immediate objections to further exploration of the idea

## Motivation

- https://domainnamewire.com/2025/06/23/domain-registrar-openprovider-exposed-transfer-codes-registrant-data-in-data-leak/


```mermaid
sequenceDiagram
    participant C as Client (Registrar)
    participant S as Server (Registry)
    
    %% 1. Initiating the Transfer Request
    C->>S: 1. <transfer op="request"> (with authInfo)
    activate S
    
    %% 2. Server acknowledges the request (Pending state)
    S-->>C: 2. Response: <result code="1000"> (Command completed successfully; action pending)
    
    %% 3. The Waiting/Decision Period (Internal process on server side)
    Note over S: Waiting Period / TLD Policy Check / Gaining Registrar Confirmation
    
    %% 4. Client polls for status (or Server sends a poll message)
    loop Checking Status until final result
        C->>S: 3a. <poll op="req">
        alt Still Pending
            S-->>C: 3b. Response: <result code="1500"> (Poll message: Still pending)
        else Transfer Completed (Success or Failure)
            S-->>C: 3b. Response: Poll Message <result code="1300/1301"> (Transfer Result: Success or Failure)
            break
        end
    end
    
    %% 5. Acknowledging the final Poll Message
    Note over C,S: Acknowledging the final result message (1300 or 1301)
    C->>S: 4. <poll op="ack"> (Acknowledgement of the final result message)
    S-->>C: 5. Response: <result code="1000"> (Command completed successfully)
    deactivate S
```
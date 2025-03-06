---
date: "2024-11-10T15:12:05Z"
draft: true
title: How to properly process messages from SQS with Lambda.
---

The other day I got some questions about using SQS as an event source for AWS Lambda. The team was investigating some issues and while looking at the code I noticed some improvements. If you're not familiar with these services there are some best practices you need to know to prevent potentials message loss or duplicate processing of events. In this posts we'll take a look at reliability strategies such as Dead-Letter Queues (DLQs), visibility timeouts, error handling, and idempotent processing.

## 1. Make use of Dead-Letter Queues (DLQs)
Define a DLQ to capture messages that fail processing after multiple attempts.



## 2. Set a correct Visibility Timeout

Set the timeout longer than the Lambda function's maximum execution time to prevent premature retries.

## 3. Implement proper error handling in your Lambda Function

Java based Lambda functions usually implements usually implement the `com.amazonaws.services.lambda.runtime.RequestHandler` or the `com.amazonaws.services.lambda.runtime.RequestStreamHandler` interface.

Ensure exceptions are thrown when processing fails so Lambda will retry.

  **Incorrect code**:
  ```java
  public class SQSLambdaHandler implements RequestHandler<SQSEvent, Void> {
      @Override
      public Void handleRequest(SQSEvent event, Context context) {
          for (SQSEvent.SQSMessage message : event.getRecords()) {
              try {
                  // Process the message
                  processMessage(message);
              } catch (Exception e) {
                  context.getLogger().log("Error processing message: " + message.getBody() + " - " + e.getMessage());
                  // Rethrow exception to trigger Lambda retry
                  throw e;
              }
          }
          return null;
      }

      private void processMessage(SQSEvent.SQSMessage message) {
          // Business logic for processing message
      }
  }
```


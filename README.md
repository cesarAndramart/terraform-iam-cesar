# terraform-iam-cesar

# Exercise 1:
## Scenario
ABC Company has created an S3 bucket named bucket-lab-iam-xidera-NOBRE. This bucket has two main folders:

1. /public/: This folder will contain files that certain users can access with read-only permissions.
2. /private/: This folder will contain internal data. Only an admin user and a backup role will have read/write access.

Additionally, an application running on Amazon EC2 needs to read files from both /public/ and /private/ but should not be allowed to perform any write or delete operations.

## Requirements
1. Group and Read-Only Policy

- A group named GrupoLectoresS3 should be created where users can only list and read objects in the /public/ folder.
- These users should not have access to read, upload, or delete objects in /private/.

2. Admin User

- A user named admin-s3 with full access (read, write, delete) to the entire bucket.
- This user should be able to view both /public/ and /private/ folders, and perform upload and delete operations in both.

3. IAM Role for EC2

- A role for the EC2 instance, named EC2S3ReadOnlyRole, should be created that allows:
   - Reading objects in both /public/ and /private/.
  - Listing the entire bucket.
  - No permission to upload or delete objects.
4. Additional Security Requirements

- Encryption at Rest: Ensure that the bucket has encryption enabled (SSE-S3 or SSE-KMS).
- Block Public Access: Ensure that the bucket is not public (using Bucket Policy or Access Block Settings).
- Auditing: Enable CloudTrail (if not already enabled in the account) to log API calls to S3 and IAM for auditing access.

## Steps to Follow

Below are the recommended steps to complete the exercise, with an estimated total time of 4 hours.

1. **Create or Verify the Bucket and Folder Structure**
- Create the bucket (if it does not exist) named bucket-lab-iam.
- Create the folders public/ and private/ within the bucket.
- Upload test files to both folders.
- Enable encryption at rest (SSE-S3 or SSE-KMS) on the bucket via the S3 configuration settings.
- In the S3 console, review the Block Public Access section and ensure that all options for blocking public access are enabled.
- Review or edit the Bucket Policy (if it exists) to ensure no public or anonymous access is allowed. (If the bucket is new and does not require additional policies, this step can be skipped.)

2. **Create the IAM Policy for "S3 Readers (/public/ folder)"**
   - Go to the IAM console and select Policies.
   - Create a policy named LecturaS3PublicPolicy that includes:

- Actions:
  - s3:ListBucket on arn:aws:s3:::bucket-lab-iam.
  - s3:GetObject on arn:aws:s3:::bucket-lab-iam/public/*.
- Do not allow access to bucket-lab-iam/private/*.
  - Save the policy and ensure it appears in the list of custom policies.
Policy json:
  Create the IAM Policy for "S3 Readers (/public/ folder)"
3.1. Go to the IAM console and select Policies.
3.2. Create a policy named LecturaS3PublicPolicy that includes:

Actions:
s3:ListBucket on arn:aws:s3:::bucket-lab-iam.
s3:GetObject on arn:aws:s3:::bucket-lab-iam/public/*.
Do not allow access to bucket-lab-iam/private/*.
- Save the policy and ensure it appears in the list of custom policies.

Json Policy:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": "<bucket_arn>/public/*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "<bucket_arn>"
        }
    ]
}
```
3. **Create the IAM Group and Add Reader Users**
   - Create a group named GrupoLectoresS3.
  - Attach the LecturaS3PublicPolicy to the group.
  - Create one or more users, such as usuario1 and usuario2.
  - Assign both users to the GrupoLectoresS3.

4. **Create and Test the **Admin User** for S3**
 
- Create an IAM user named `admin-s3`.
-  Assign the user full access to S3 by either using the AWS managed policy `AmazonS3FullAccess` or creating a custom policy that includes `s3:*` for `arn:aws:s3:::bucket-lab-iam/*`.
-   **Verify**:  
   - That `admin-s3` can list and read both `/public/` and `/private/` folders.  
   - That `admin-s3` can **upload** and **delete** objects in both folders.  

---

5. **Create the **IAM Role** for EC2 with Read-Only Access**

- Go to the IAM console → **Roles**.
- Create a role named `EC2S3ReadOnlyRole`.  
   - **Trusted Entity**: Select **AWS service → EC2**.
-  Attach a read-only policy for the entire bucket. You can either duplicate the "read" policy for `/public/` and extend it for `arn:aws:s3:::bucket-lab-iam/*`, or use the AWS managed policy `AmazonS3ReadOnlyAccess`.  
- Configure your EC2 instance (new or existing) to assume the role `EC2S3ReadOnlyRole` (in the **IAM Role** section of the instance configuration).  

---

6. **Enable CloudTrail for Auditing (Optional but Recommended)**

- If not already enabled, go to the CloudTrail console and create a **Trail** to log API calls to S3 and IAM at the account level.
-  Associate a destination bucket for CloudTrail logs (it can be a different bucket than the one used in this exercise).
-   Verify that events such as user creation, policy attachment, etc., are being logged.  

---

### 7. **Validation Tests**

1. **Users in the read-only group** (`usuario1` and `usuario2`):  
   - Use AWS CLI (or the web console) to **list** the bucket. It should succeed.  
   - Try to **download** an object from the `/public/` folder. It should succeed.  
   - Try to **read** an object from the `/private/` folder. It should **fail** due to lack of permissions.  
   - Try to **upload** or **delete** objects in `/public/`. It should fail.  
![evidencia1](https://github.com/user-attachments/assets/2dadf4db-d6af-4ed3-aff8-822d0eebf90d)

2. **Admin user** (`admin-s3`):  
   - **List** and **read** all objects.  
   - **Upload** an object to `/private/`. It should succeed.  
   - **Delete** an object in `/public/`. It should succeed.  
![evidencia 2](https://github.com/user-attachments/assets/eebcd643-b66b-4ec4-93fe-1763c38c4b4e)

3. **EC2 instance with role `EC2S3ReadOnlyRole`**:  
   - Connect to the EC2 instance (via SSH or Session Manager).  
   - Run the following commands:  
     ```bash
     aws s3 ls s3://bucket-lab-iam
     aws s3 cp s3://bucket-lab-iam/private/ejemplo.txt .
     aws s3 cp s3://bucket-lab-iam/public/otro-archivo.txt .
     ```  
   - Verify that **downloading** works without issues.  
   - Try to **upload** a file (e.g., `aws s3 cp localfile.txt s3://bucket-lab-iam/private/`) and confirm that it fails due to insufficient permissions.  
![evidencia3](https://github.com/user-attachments/assets/3d714f7d-c9d4-4dd5-a372-d79e4bfd1d0b)

# Exercise 2: Terraform IAM Lambda

This exercise expects the creation of a **Terraform** (main.tf) module to manage AWS Identity and Access Management (IAM) resources, specifically for creating and managing a custom policy for AWS Lambda access. The project includes the creation of:

- A custom IAM policy allowing **listing** and **creating** Lambda functions.
- An **IAM group** to which this policy is attached.
- An **IAM user** assigned to the group with the corresponding permissions.
  
## Project Overview

### Resources Managed

1. **AWS IAM Policy**: A custom policy allowing the actions `lambda:ListFunctions` and `lambda:CreateFunction` on all resources (`*`).
2. **AWS IAM Group**: A group created to attach the custom policy.
3. **AWS IAM User**: A user that is added to the IAM group to inherit the permissions granted by the attached policy.

### Outputs

- **Policy ARN**: The ARN of the Lambda policy created.
- **IAM Group Name**: The name of the IAM group for Lambda access.


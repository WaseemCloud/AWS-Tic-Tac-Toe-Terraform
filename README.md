# Tic-Tac-Toe Full Deployment using Terraform on AWS 🚀☁️


![d4747cb7dcbecb5223b83355ea97a3be-removebg-preview](https://github.com/WaseemCloud/Tic-Tac-Toe-AI-Game-on-AWS-Management-Console-/assets/157589909/6c41585d-d5de-467c-835c-da0cbfe15838)

This project is showcasing the power of IaC, where you can re-produce your entire "Tic-Tac-Toe" configuration in a matter of minutes using Terraform.

Checkout the previous "Tic-Tac-Toe" project, which is fully explained, and deployed using AWS Management Console:

https://github.com/WaseemCloud/AWS-Tic-Tac-Toe-AI-Game-on-Management-Console-

A full step-by-step tutorial has been recorded and uploaded to my Youtube channel:

👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇👇

https://www.youtube.com/watch?v=6dRIrwBlDdg

-----------------------------

- Clone this repository locally to your machine.
- Make sure to comment the resource block that is responsible to upload your objects to S3. The reason for this, that you will need to update your script.js file with the Invoke URL of the API Gateway.

- Initialize your Terraform backend:


      terraform init

- Apply your infrastructure:


      terraform apply -var-file vars.tfvars


- Before updating your Javascript file with the API invoke URL, make sure to enable then again disable the "Lambda proxy integration" option under "Integration request" in the api resource settings:

![Screen Shot 2024-03-24 at 2 57 04 PM](https://github.com/WaseemCloud/AWS-Tic-Tac-Toe-Terraform/assets/157589909/cc575f0d-d542-42bd-a520-c3d41123bef9)


- Click on "Edit", and enable it:
  

![Screen Shot 2024-03-24 at 2 58 59 PM](https://github.com/WaseemCloud/AWS-Tic-Tac-Toe-Terraform/assets/157589909/8e53743a-86b8-4768-898c-d4d063c4b9df)


- Click on "save", again click on "Edit" one more time, then re-disable it again:
  

![Screen Shot 2024-03-24 at 2 59 58 PM](https://github.com/WaseemCloud/AWS-Tic-Tac-Toe-Terraform/assets/157589909/3c2e44d9-9871-462c-8eb7-9ffcb98980dc)
  
- Now you can retreive your API Invoke URL, and update your "script.js" file with it.

- Uncomment the resource block for uploading objects to your S3, and run apply again:
  
      terraform apply -var-file vars.tfvars
  




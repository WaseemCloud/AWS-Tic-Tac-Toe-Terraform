# Tic-Tac-Toe Full Deployment using Terraform on AWS 🚀☁️

![d4747cb7dcbecb5223b83355ea97a3be-removebg-preview](https://github.com/WaseemCloud/Tic-Tac-Toe-AI-Game-on-AWS-Management-Console-/assets/157589909/6c41585d-d5de-467c-835c-da0cbfe15838)


- Make sure to comment the section that is responsible for uploading your website files to the S3.
- Before updating your Javascript file with the API invoke URL, make sure to enable then again disable the "Lambda proxy integration" option under "Integration request" in the api resource settings.
- As soon as you update your Javascript code with the invoke url, uncomment the section that is responsible for the files upload, and hit the followin command one more time:
  
      terraform apply -var-file vars.tfvars
  

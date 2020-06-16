 
#!/bin/bash

set -e -u # Exit script on error and treat unset variables as an error

echo -e "${BLUE}Executing deployment...${NC}"

echo -e "${GREEN}Creating resource group [${RG_NAME}] in subscription [${SUBSCRIPTION_ID}]...${NC}"

echo -e "${GREEN}Creating container registry [${ACR_NAME}] in resource group [${RG_NAME}]...${NC}"

echo -e "${GREEN}Importing runner image [${RUNNER_IMAGE}] into container registry [${ACR_NAME}]...${NC}"

echo -e "${GREEN}Creating VM [${VM_NAME}] in resource group [${RG_NAME}]...${NC}"

echo -e "${GREEN}Deleting NSG rule [${NSG_RULE_NAME}] in NSG [${RG_NAME}]...${NC}"

echo -e "${GREEN}Configuring VM [${VM_NAME}] with system-managed identity...${NC}"

echo -e "${GREEN}Granting system-managed identity [${VM_IDENTITY}] access to container registry [${ACR_ID}]...${NC}"

echo -e "${GREEN}Installing VM extension [${VM_EXT_NAME}] in VM [${VM_NAME}]...${NC}"

echo -e "${BLUE}Deployment completed successfully.${NC}"
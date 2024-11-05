
This README will guide users on how to set up, configure, and run the script for automating the creation of ArgoCD applications using GitLab repositories.

---

# ArgoCD Application Deployment Script

This script automates the process of creating ArgoCD applications for each project in a GitLab group and deploys them to a Kubernetes cluster. It fetches project names from a specified GitLab group, generates application YAML files, and applies them to your Kubernetes cluster using `kubectl`.

## Prerequisites

Before using the script, ensure the following prerequisites are met:

1. **GitLab Access**:
   - A GitLab account with access to the GitLab repositories.
   - A GitLab **Personal Access Token** with sufficient permissions to access the repositories.

2. **ArgoCD**:
   - ArgoCD must be installed and running in your Kubernetes cluster.

3. **Kubernetes**:
   - A running Kubernetes cluster.
   - `kubectl` configured to interact with the cluster.

## Installation

1. **Clone the Repository**:

    Clone or download this script to your local machine.

    ```bash
    git clone https://github.com/namigazimli/argocd-apps-automation.git
    cd argocd-apps-automation
    ```

2. **Update the Script**:
   
    - Replace the `YOUR_GITLAB_FQDN` and `YOUR_PRIVATE_TOKEN` placeholders with your GitLab instance URL and personal access token.
    - Ensure your Kubernetes `kubectl` is configured correctly to access the target cluster.

## Configuration

The script will prompt you to input the following details:

1. **ArgoCD URL**: The URL of your ArgoCD instance (e.g., `https://argocd.example.com`).
2. **Project Name**: The name of the ArgoCD project under which the applications will be created.
3. **Chart Folder**: The folder in the Git repository where the Helm charts are located.
4. **GitLab Group ID**: The GitLab Group ID containing the repositories.
5. **GitLab Group Name**: The GitLab group name under which the repositories are organized.
6. **GitLab Subgroup Name**: The subgroup under the GitLab group, if applicable.
7. **GitLab CI Username and Password**: The GitLab CI username and password for authentication (if needed).
8. **Kubernetes Namespace**: The namespace in Kubernetes where the applications will be deployed.

## Usage

### Step 1: Run the Script

Execute the script to start the process. The script will prompt you for the required information, then proceed to:

1. Fetch project names from the specified GitLab group.
2. For each project, generate an ArgoCD application YAML file using a template.
3. Apply the generated YAML file to your Kubernetes cluster using `kubectl`.

```bash
./deploy-argocd-applications.sh
```

The script will automatically create ArgoCD application resources in your Kubernetes cluster.

### Step 2: ArgoCD Sync

Once the applications are created, you can either manually sync them from the ArgoCD UI or enable automated syncing (which the script does by default). The applications will be created in the `argocd` namespace by default.

### Example of `application.yaml`

The generated ArgoCD application YAML looks like this:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: ${CHART_FOLDER}-${BRANCH_NAME}-${i}
  namespace: argocd
spec:
  project: ${PROJ_NAME}
  source:
    repoURL: ${GITLAB_URL}/${GROUP_NAME}/${SUBGROUP_NAME}/${CHART_FOLDER}/${i}.git
    path: .
    targetRevision: ${BRANCH_NAME}
    helm:
      valueFiles: 
      - ${BRANCH_NAME}.yaml
  destination:
    namespace: ${DEST_NAMESPACE}
    server: ${K8S_SERVER}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```
---

# GitLab to ArgoCD Repository Integration Script

This script automates the process of adding GitLab repositories to an ArgoCD instance, based on the GitLab group and subgroup you provide. The script fetches all the projects from the specified GitLab group and adds them as repositories to your ArgoCD instance.

## Prerequisites

Before running the script, ensure you have the following tools and credentials:

1. **jq**: A lightweight and flexible command-line JSON processor.
2. **GitLab Private Token**: You need a private token from GitLab to interact with the GitLab API.
3. **ArgoCD**: The script adds GitLab repositories to your ArgoCD instance.
4. **GitLab CI credentials**: These credentials are used to authenticate against GitLab when adding repositories.

### Installation Requirements:

- **jq**: The script will attempt to install `jq` if it's not already installed on your system.
- **curl**: The script uses `curl` to interact with GitLab API.
- **argocd CLI**: The script uses the `argocd` command-line interface to manage repositories on your ArgoCD instance.

---

## Usage

### 1. Input Prompts

The script will prompt you to enter the following details:

- **ArgoCD URL**: The base URL of your ArgoCD instance (e.g., `https://argocd.example.com`).
- **Project Name**: The name of the ArgoCD project you want to associate with the repositories.
- **Chart Folder**: The folder containing Helm charts that you want to use in ArgoCD.
- **GitLab Group ID**: The ID of the GitLab group that contains the projects.
- **GitLab Group Name**: The name of the GitLab group that contains the projects.
- **GitLab Subgroup Name**: The name of the GitLab subgroup (if any).
- **ArgoCD Admin Username**: The admin username for logging into your ArgoCD instance.
- **ArgoCD Admin Password**: The admin password for logging into your ArgoCD instance.
- **GitLab CI Username**: The GitLab CI username for authenticating against GitLab.
- **GitLab CI Password**: The GitLab CI password for authenticating against GitLab.

### 2. Script Execution Flow

1. The script will first check if `jq` is installed and install it if not.
2. It will then use the provided GitLab API credentials to fetch all projects from the specified GitLab group and subgroup.
3. The fetched project names will be transformed to lowercase.
4. The script will log into your ArgoCD instance using the provided admin credentials.
5. It will then iterate through the fetched GitLab projects and add each project repository to ArgoCD.

---

## Example

### Example Command:

```bash
./gitlab_to_argocd.sh
```

### Example Inputs:

```
Enter your ArgoCD URL: https://argocd.example.com
Enter your Project name: my-argocd-project
Enter the chart folder name which you want to use it in ArgoCD application: charts
Enter the GITLAB GROUP ID: 123
Enter the GITLAB GROUP NAME: example-group
Enter the GITLAB SUBGROUP NAME: example-subgroup
Enter ArgoCD admin username: admin
Enter ArgoCD admin user password: password123
Enter Gitlab CI username: ciuser
Enter Gitlab CI user password: ciuserpass
```

---

## Notes

- Ensure that the GitLab private token has the necessary permissions to access the group and its projects.
- The script assumes that all repositories follow the same folder structure in GitLab (`$GITLAB_URL/$GROUP_NAME/$SUBGROUP_NAME/${CHART_FOLDER}/$i.git`).
- If there are no projects in the GitLab group, the script will exit with an error message.

---

# ArgoCD Project Creation Script

This script automates the process of creating a new ArgoCD `AppProject` by using a YAML template and applying it to a Kubernetes cluster. The script prompts you for the necessary project information, substitutes it into the template, and applies the configuration to your Kubernetes environment.

## Prerequisites

Before running the script, ensure you have the following tools installed and configured:

1. **Kubernetes CLI (`kubectl`)**: The script uses `kubectl` to apply the YAML configuration to your Kubernetes cluster.
2. **ArgoCD**: You must have ArgoCD installed and running in your cluster to manage the project.
3. **Template File**: The script uses a template file (`project.yaml.temp`) for generating the final project YAML. This template file should be located in the same directory as the script.

## Installation

### Step 1: Clone or Download the Script

You can download or clone the script to your system.

```bash
git clone <repository-url>
cd <script-directory>
```

### Step 2: Create or Ensure the Existence of `project.yaml.temp`

The script uses a temporary YAML file (`project.yaml.temp`) to generate the final ArgoCD `AppProject`. Ensure that this template file exists and is structured correctly.

#### Example `project.yaml.temp` template:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: ${PROJ_NAME}
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  description: ${PROJ_DESC}
  destinations:
  - name: '*'
    namespace: '*'
    server: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
```

### Step 3: Make the Script Executable

Ensure that the script has executable permissions:

```bash
chmod +x create_argocd_project.sh
```

---

## Usage

### Running the Script

Execute the script as follows:

```bash
./create_argocd_project.sh
```

The script will prompt you for the following inputs:

- **Project Name**: The name of your ArgoCD project (e.g., `my-argocd-project`).
- **Project Description**: A short description of the project (e.g., `This is my first ArgoCD project`).

### Example Execution:

```bash
Enter your Project name: my-argocd-project
Enter your Project description: This is my first ArgoCD project
```

Once you provide the inputs, the script will:

1. Substitute the entered values (`PROJ_NAME` and `PROJ_DESC`) into the `project.yaml.temp` template.
2. Generate a new file named `project.yaml`.
3. Apply the `project.yaml` file to your Kubernetes cluster using `kubectl`.

---

## Example Project YAML

After the script runs, it will create a project definition like the following:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: my-argocd-project
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  description: This is my first ArgoCD project
  destinations:
  - name: '*'
    namespace: '*'
    server: '*'
  namespaceResourceWhitelist:
  - group: '*'
    kind: '*'
  sourceRepos:
  - '*'
```

This YAML will define an ArgoCD project with the specified name and description, along with default settings for resources, namespaces, and source repositories.

---

## Notes

- **Customization**: The `project.yaml.temp` template is a starting point. You can customize it further to suit your specific ArgoCD project requirements, such as restricting the repositories or namespaces that can be used by the project.
- **Cluster Access**: Ensure that you have the necessary permissions to create resources in the `argocd` namespace within your Kubernetes cluster.
- **ArgoCD Project Namespace**: This script assumes that the `argocd` namespace exists in your cluster. If not, ensure that the namespace is created before applying the project configuration.

---

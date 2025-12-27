# Homepage Secrets Configuration

This guide explains how to configure API tokens for ArgoCD and GitLab integrations.

## 🔐 Required Secrets

Homepage uses the following secrets for service integrations:

1. **ArgoCD Token** - For displaying ArgoCD application stats
2. **GitLab Token** - For displaying GitLab group repository count

## 📋 Creating Secrets in OpenShift/Kubernetes

### Method 1: Using oc/kubectl Command

```bash
# Create the secret with both tokens
oc create secret generic homepage-secrets \
  --from-literal=argocd-token='YOUR_ARGOCD_TOKEN_HERE' \
  --from-literal=gitlab-token='YOUR_GITLAB_TOKEN_HERE' \
  -n your-namespace
```

### Method 2: Using YAML Manifest

Create a file `homepage-secrets.yaml`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: homepage-secrets
  namespace: your-namespace
type: Opaque
stringData:
  argocd-token: "YOUR_ARGOCD_TOKEN_HERE"
  gitlab-token: "YOUR_GITLAB_TOKEN_HERE"
```

Apply it:
```bash
oc apply -f homepage-secrets.yaml
```

### Method 3: Base64 Encoded (More Secure)

```bash
# Encode your tokens
echo -n 'YOUR_ARGOCD_TOKEN' | base64
echo -n 'YOUR_GITLAB_TOKEN' | base64
```

Create `homepage-secrets.yaml`:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: homepage-secrets
  namespace: your-namespace
type: Opaque
data:
  argocd-token: <BASE64_ENCODED_ARGOCD_TOKEN>
  gitlab-token: <BASE64_ENCODED_GITLAB_TOKEN>
```

## 🎯 Obtaining API Tokens

### ArgoCD Token

1. **Login to ArgoCD CLI**:
   ```bash
   argocd login argocd.internal.local
   ```

2. **Create account token**:
   ```bash
   argocd account generate-token --account homepage
   ```

   Or create a project token:
   ```bash
   argocd proj role create-token YOUR_PROJECT readonly
   ```

3. **Alternative: Use existing account**:
   - Login to ArgoCD UI
   - Go to Settings → Accounts
   - Create a new account or use existing
   - Generate token

### GitLab Token

1. **Login to GitLab**
2. **Go to User Settings → Access Tokens**
3. **Create Personal Access Token**:
   - Name: `homepage-dashboard`
   - Scopes: `read_api` (minimum required)
   - Expiration: Set according to your security policy

4. **For Service Accounts** (Recommended):
   - Create a dedicated service account user
   - Generate token for that account
   - Add to your team group with Reporter role

## 🐳 Docker/Podman Configuration

For local development with Docker/Podman, add tokens to `docker-compose.yml`:

### Method 1: Direct Environment Variables

```yaml
environment:
  HOMEPAGE_VAR_ARGOCD_TOKEN: "your-argocd-token"
  HOMEPAGE_VAR_GITLAB_TOKEN: "your-gitlab-token"
```

### Method 2: Using .env File (Recommended)

Create `.env` file:
```bash
HOMEPAGE_VAR_ARGOCD_TOKEN=your-argocd-token
HOMEPAGE_VAR_GITLAB_TOKEN=your-gitlab-token
```

Update `docker-compose.yml`:
```yaml
environment:
  HOMEPAGE_VAR_ARGOCD_TOKEN: ${HOMEPAGE_VAR_ARGOCD_TOKEN}
  HOMEPAGE_VAR_GITLAB_TOKEN: ${HOMEPAGE_VAR_GITLAB_TOKEN}
```

**Important**: Add `.env` to `.gitignore`!

## 🔒 Security Best Practices

1. **Never commit secrets to git**
   - Add `.env` to `.gitignore`
   - Use secret management tools (Vault, Sealed Secrets)

2. **Use least privilege**
   - ArgoCD: Read-only access
   - GitLab: `read_api` scope only

3. **Rotate tokens regularly**
   - Set expiration dates
   - Update secrets when rotating

4. **Use service accounts**
   - Create dedicated service accounts
   - Don't use personal tokens in production

5. **For Air-Gapped Environments**
   - Ensure tokens work with internal instances
   - Test connectivity before deployment

## ✅ Verification

### Check Secret in OpenShift

```bash
# Verify secret exists
oc get secret homepage-secrets -n your-namespace

# Check secret data (base64 encoded)
oc get secret homepage-secrets -o yaml

# Decode to verify (be careful in production!)
oc get secret homepage-secrets -o jsonpath='{.data.argocd-token}' | base64 -d
```

### Test Tokens

**ArgoCD**:
```bash
curl -H "Authorization: Bearer YOUR_ARGOCD_TOKEN" \
  https://argocd.internal.local/api/v1/applications
```

**GitLab**:
```bash
curl -H "PRIVATE-TOKEN: YOUR_GITLAB_TOKEN" \
  "https://gitlab.internal.local/api/v4/groups/your-team/projects"
```

## 🚨 Troubleshooting

### Widgets not showing data

1. **Check secret is mounted**:
   ```bash
   oc exec -it <homepage-pod> -- env | grep HOMEPAGE_VAR
   ```

2. **Verify token format**:
   - Tokens should have no extra spaces or newlines
   - Check base64 encoding is correct

3. **Check API connectivity**:
   ```bash
   # From inside the pod
   oc exec -it <homepage-pod> -- curl -k https://argocd.internal.local/api/version
   ```

4. **Check logs**:
   ```bash
   oc logs <homepage-pod> | grep -i error
   ```

### Common Errors

| Error | Solution |
|-------|----------|
| `401 Unauthorized` | Token is invalid or expired |
| `403 Forbidden` | Token lacks required permissions |
| `404 Not Found` | Wrong URL or group path |
| `Secret not found` | Secret not created or wrong namespace |

## 📝 Example Secret for Testing

For **testing only** (not production):

```bash
# Create test secret
oc create secret generic homepage-secrets \
  --from-literal=argocd-token='test-token-replace-me' \
  --from-literal=gitlab-token='test-token-replace-me' \
  -n homepage
```

The widgets will fail gracefully if tokens are invalid, showing "API Error" instead of data.

---

**Security Note**: Keep your tokens secure and rotate them regularly! 🔐
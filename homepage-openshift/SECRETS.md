# API Token Configuration

Guide for configuring ArgoCD and GitLab API tokens for Homepage widgets.

## Overview

Homepage needs API tokens to display widget data:
- **ArgoCD Token** - Shows application count and health status
- **GitLab Token** - Shows repository count for team groups

Tokens are stored in Kubernetes secrets and injected as environment variables.

## Creating the Secret

### Quick Method

```bash
# Create secret with both tokens
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="YOUR_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="YOUR_GITLAB_TOKEN"
```

### Verify Secret

```bash
# Check secret exists
oc get secret homepage-secrets

# View secret contents (base64 encoded)
oc get secret homepage-secrets -o yaml
```

## Generating Tokens

### ArgoCD Token

1. **Login to ArgoCD UI**
2. **Navigate to**: User Info → Account Settings
3. **Generate Token**:
   - Name: `homepage-widget`
   - Expires: Never (or set expiration)
4. **Copy the token** - it won't be shown again

**Via CLI:**
```bash
# Generate token via argocd CLI
argocd account generate-token --account homepage
```

### GitLab Token

1. **Login to GitLab**
2. **Navigate to**: User Settings → Access Tokens
3. **Create Token**:
   - Name: `homepage-widget`
   - Scopes: `read_api`, `read_repository`
   - Expiration: Optional
4. **Copy the token**

**Token format:** `glpat-xxxxxxxxxxxxxxxxxxxx`

## Updating Tokens

### Update Existing Secret

```bash
# Update ArgoCD token
oc patch secret homepage-secrets \
  -p '{"data":{"argocd-token":"'$(echo -n "NEW_TOKEN" | base64)'"}}'

# Update GitLab token
oc patch secret homepage-secrets \
  -p '{"data":{"gitlab-token":"'$(echo -n "NEW_TOKEN" | base64)'"}}'
```

### Recreate Secret

```bash
# Delete old secret
oc delete secret homepage-secrets

# Create new secret
oc create secret generic homepage-secrets \
  --from-literal=argocd-token="NEW_ARGOCD_TOKEN" \
  --from-literal=gitlab-token="NEW_GITLAB_TOKEN"

# Restart pods to pick up new secret
oc rollout restart deployment/homepage
```

## Verifying Token Configuration

### Check Environment Variables

```bash
# Verify tokens are injected into pod
oc exec -it $(oc get pod -l app.kubernetes.io/name=homepage -o name) -- env | grep HOMEPAGE_VAR

# Expected output:
# HOMEPAGE_VAR_ARGOCD_TOKEN=your-token-here
# HOMEPAGE_VAR_GITLAB_TOKEN=your-token-here
```

### Test Widget Functionality

```bash
# Check Homepage logs for errors
oc logs -l app.kubernetes.io/name=homepage | grep -i "error\|token\|widget"

# Should see NO authentication errors
```

## Troubleshooting

### Widgets Show "Error" or Empty

**Check token validity:**
```bash
# Test ArgoCD token
curl -k https://argocd.internal.local/api/v1/applications \
  -H "Authorization: Bearer YOUR_ARGOCD_TOKEN"

# Test GitLab token
curl https://gitlab.internal.local/api/v4/groups/your-team/projects \
  -H "PRIVATE-TOKEN: YOUR_GITLAB_TOKEN"
```

### Tokens Not Injected

**Verify secret reference:**
```bash
# Check deployment env configuration
oc get deployment homepage -o yaml | grep -A 10 "env:"
```

### Permission Errors

**ArgoCD**: Ensure token has read permissions on applications
**GitLab**: Ensure token has `read_api` scope

## Security Best Practices

1. **Use service accounts** instead of personal tokens
2. **Set token expiration** (30-90 days recommended)
3. **Rotate tokens regularly** (quarterly)
4. **Use RBAC** to limit secret access
5. **Never commit tokens** to Git repositories

## Optional: Service Account Tokens

### ArgoCD Service Account

```bash
# Create service account in ArgoCD
argocd account create homepage --account-policy readonly

# Generate token for service account
argocd account generate-token --account homepage
```

### GitLab Project Access Token

1. Navigate to: Project → Settings → Access Tokens
2. Create project-scoped token instead of personal token
3. Scopes: `read_api`, `read_repository`

## Related Documentation

- [Helm Chart README](README.md)
- [Main README](../README.md)
- [ArgoCD Token Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_account_generate-token/)
- [GitLab Token Documentation](https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html)

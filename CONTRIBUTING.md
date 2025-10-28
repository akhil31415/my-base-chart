# Contributing to Privacera Base Helm Chart

Thank you for your interest in contributing to this project! This document provides guidelines and information for contributors.

## 🚀 Getting Started

### Prerequisites
- Helm 3.0+
- Kubernetes cluster for testing
- Git

### Development Setup
1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/my-base-chart.git
   cd my-base-chart
   ```

3. Install dependencies:
   ```bash
   helm dependency update charts/privacera-base-chart
   ```

## 📋 How to Contribute

### Reporting Issues
- Use the [GitHub Issues](https://github.com/evilgenius-jp/my-base-chart/issues) page
- Search existing issues before creating a new one
- Provide clear reproduction steps
- Include Helm and Kubernetes versions

### Suggesting Features
- Open a [GitHub Discussion](https://github.com/evilgenius-jp/my-base-chart/discussions)
- Explain the use case and benefits
- Provide examples if possible

### Code Contributions

#### 1. Chart Changes
- **Automated Testing**: All chart changes are automatically tested on PRs via GitHub Actions
- Test changes locally:
  ```bash
  # Run all tests
  ./scripts/test-examples.sh
  
  # Or test individual configurations
  helm lint charts/privacera-base-chart
  helm template test charts/privacera-base-chart
  
  # Test cloud-specific configurations
  helm template test charts/privacera-base-chart -f charts/privacera-base-chart/examples/test-aws-eks.yaml
  helm template test charts/privacera-base-chart -f charts/privacera-base-chart/examples/test-azure-aks.yaml
  helm template test charts/privacera-base-chart -f charts/privacera-base-chart/examples/test-gcp-gke.yaml
  ```

- Test with different values:
  ```bash
  helm install test-release charts/privacera-base-chart -f examples/basic-microservice.yaml --dry-run
  ```

#### 2. Documentation Updates
- Update README.md for user-facing changes
- Update values.yaml comments for new configuration options
- Add examples in the `examples/` directory

#### 3. Version Updates
- Follow [Semantic Versioning](https://semver.org/)
- Update `version` in Chart.yaml for chart changes
- Update `appVersion` in Chart.yaml for application version changes

### Pull Request Process

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow existing code style
   - Add/update tests where applicable
   - Update documentation

3. **Test thoroughly**:
   ```bash
   # Lint the chart
   helm lint charts/privacera-base-chart
   
   # Test template rendering
   helm template test charts/privacera-base-chart --values examples/basic-microservice.yaml
   
   # Test installation (if you have a cluster)
   helm install test charts/privacera-base-chart --values examples/basic-microservice.yaml --dry-run
   ```

4. **Commit and push**:
   ```bash
   git add .
   git commit -m "feat: add new feature description"
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request**:
   - Use a clear, descriptive title
   - Reference related issues
   - Explain what changed and why
   - Include testing steps

## 🎯 Chart Development Guidelines

### Template Best Practices
- Use `include` for reusable template parts
- Validate required values with `required` function
- Use `default` function for optional values
- Add helpful comments in templates

### Values Structure
- Group related configurations
- Use clear, descriptive names
- Provide sensible defaults
- Add comprehensive comments

### Testing

#### Automated Testing
- **GitHub Actions**: All PRs automatically test chart changes
- **Cloud Configurations**: Tests AWS, Azure, GCP, and generic configurations
- **Example Validation**: Tests all example files in `examples/` directory

#### Manual Testing
```bash
# Run all automated tests
./scripts/test-examples.sh

# Test specific cloud configuration
helm template test ./charts/privacera-base-chart \
  -f charts/privacera-base-chart/examples/test-aws-eks.yaml

# Verify annotations are cloud-specific
helm template test ./charts/privacera-base-chart \
  -f charts/privacera-base-chart/examples/test-aws-eks.yaml | grep "alb.ingress"
```

#### Testing Requirements
- Test with minimal values
- Test with complex configurations
- Test both Deployment and StatefulSet modes
- Verify resource generation
- **Test cloud-agnostic behavior**: Verify only specified cloud's annotations appear

### Documentation
- Update values.yaml comments
- Add examples for new features
- Update README.md for breaking changes

## 📝 Commit Message Guidelines

Use conventional commits format:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test changes
- `chore`: Maintenance tasks

Examples:
- `feat(templates): add support for init containers`
- `fix(service): correct port configuration`
- `docs(readme): update installation instructions`

## 🔄 Release Process

Releases are automated via GitHub Actions:

1. **PR Testing**: All PRs automatically test chart changes with multiple cloud configurations
2. **Merge to main**: Changes merged to main trigger the release workflow
3. **Chart packaging**: Charts are automatically packaged and released
4. **GitHub Pages**: Repository index is updated on GitHub Pages
5. **GitHub Releases**: Release notes are automatically generated

### Testing Workflow

The automated testing workflow (`.github/workflows/test-charts.yml`) runs on every PR and push to main:

- ✅ Tests all cloud configurations (AWS, Azure, GCP, generic)
- ✅ Validates service account annotations per cloud
- ✅ Verifies no cross-cloud annotations appear
- ✅ Lints all example files
- ✅ Ensures templates render successfully

Failed tests will block PR merges until issues are resolved.

### Manual Release (if needed)
```bash
# Package chart
helm package charts/privacera-base-chart

# Update repository index
helm repo index . --url https://evilgenius-jp.github.io/my-base-chart/

# Commit and push
git add .
git commit -m "chore: release version X.Y.Z"
git push origin main
```

## 📞 Getting Help

- **Questions**: Use [GitHub Discussions](https://github.com/evilgenius-jp/my-base-chart/discussions)
- **Issues**: Use [GitHub Issues](https://github.com/evilgenius-jp/my-base-chart/issues)
- **Chat**: Join our community chat (link TBD)

## 🏆 Recognition

Contributors will be:
- Listed in release notes
- Added to the contributors section
- Recognized in the community

Thank you for contributing! 🎉

# Contributing to SIPEN-GO

Thank you for your interest in contributing to SIPEN-GO! This document provides guidelines for contributing to the project.

## Code of Conduct

- Be respectful and professional
- Provide constructive feedback
- Focus on code quality and user experience
- Report issues responsibly

## Getting Started

1. Read `SETUP.md` for development environment setup
2. Read `ARCHITECTURE.md` for code structure
3. Read `README.md` for feature overview
4. Fork the repository
5. Create a feature branch

## Development Guidelines

### Code Style

#### Dart/Flutter
- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable names
- Add comments for complex logic
- Keep functions small and focused
- Use type annotations

#### Example
```dart
// Good
Future<List<FamilyModel>> getFamiliesByAddress(String address) async {
  final response = await supabase
      .from('families')
      .select()
      .ilike('address', '%$address%');
  
  return (response as List)
      .map((e) => FamilyModel.fromJson(e))
      .toList();
}

// Avoid
Future getFamilies(a) async {
  var r = await supabase.from('families').select().ilike('address', '%$a%');
  return r.map((e) => FamilyModel.fromJson(e)).toList();
}
```

### Architecture

Follow Clean Architecture with MVVM:

```
Presentation (UI)
    ↓
Domain (Business Logic)
    ↓
Data (Repositories & Services)
```

### File Organization

- One class per file (except related small classes)
- Logical folder structure
- Clear naming conventions
- Consistent imports

### Naming Conventions

| Type | Convention | Example |
|------|-----------|---------|
| Classes | PascalCase | `FamilyModel`, `LoginScreen` |
| Functions | camelCase | `getFamilies()`, `validateEmail()` |
| Variables | camelCase | `familyList`, `isLoading` |
| Constants | camelCase | `defaultTimeout`, `maxRetries` |
| Files | snake_case | `family_model.dart`, `login_screen.dart` |
| Folders | snake_case | `lib/data/models/`, `lib/presentation/screens/` |

### Comments

```dart
// Single line comment for brief explanations
// Use for simple clarifications

/// Documentation comment for public APIs
/// Use for classes, functions, and public members
/// Can span multiple lines

/* Multi-line comment for complex explanations */
```

### Error Handling

```dart
// Good
try {
  final family = await familyRepository.getFamily(id);
  return family;
} catch (e) {
  print('Error loading family: $e');
  rethrow; // Let caller handle
}

// Avoid
try {
  return await familyRepository.getFamily(id);
} catch (e) {
  // Silent failure - bad!
}
```

## Git Workflow

### Branch Naming

```
feature/feature-name          # New feature
bugfix/bug-description        # Bug fix
refactor/refactor-description # Code refactoring
docs/documentation-update     # Documentation
```

### Commit Messages

```
# Good
git commit -m "Add family search by address"
git commit -m "Fix overflow on search bar"
git commit -m "Update README with setup instructions"

# Avoid
git commit -m "fix"
git commit -m "update stuff"
git commit -m "WIP"
```

### Pull Request Process

1. Create feature branch from `main`
2. Make changes following guidelines
3. Test thoroughly
4. Push to your fork
5. Create Pull Request with:
   - Clear title
   - Description of changes
   - Related issues (if any)
   - Screenshots (for UI changes)
6. Address review comments
7. Merge after approval

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New feature
- [ ] Bug fix
- [ ] Documentation update
- [ ] Code refactoring

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Web
- [ ] All tests pass

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Closes #123
```

## Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test integration_test/
```

### All Tests
```bash
flutter test
```

### Writing Tests
```dart
void main() {
  group('FamilyRepository', () {
    test('getFamilies returns list of families', () async {
      // Arrange
      final repository = FamilyRepository();
      
      // Act
      final families = await repository.getFamilies();
      
      // Assert
      expect(families, isNotEmpty);
      expect(families.first, isA<FamilyModel>());
    });
  });
}
```

## Documentation

### Code Documentation
- Add comments for complex logic
- Document public APIs with `///`
- Include examples in documentation
- Keep documentation up-to-date

### README Updates
- Update if adding new features
- Include setup instructions for new dependencies
- Add troubleshooting if needed

### Architecture Documentation
- Update `ARCHITECTURE.md` for major changes
- Update `PROJECT_STRUCTURE.md` if adding new folders
- Keep diagrams current

## Performance Considerations

### Do's
- Use `const` constructors
- Implement `==` and `hashCode` for models
- Use `ListView.builder` for long lists
- Cache expensive computations
- Use `FutureProvider` for async operations

### Don'ts
- Don't rebuild entire widget tree unnecessarily
- Don't make synchronous network calls
- Don't load all data at once
- Don't ignore performance warnings
- Don't use `setState` in complex widgets

## Security Considerations

### Do's
- Validate all user inputs
- Use HTTPS for all network calls
- Store sensitive data securely
- Implement proper authentication
- Use RLS policies in database

### Don'ts
- Don't hardcode credentials
- Don't log sensitive information
- Don't trust user input
- Don't expose API keys
- Don't skip validation

## Accessibility

### Do's
- Use semantic widgets
- Provide meaningful labels
- Support screen readers
- Use sufficient color contrast
- Test with accessibility tools

### Don'ts
- Don't rely only on color
- Don't use very small text
- Don't ignore accessibility warnings
- Don't create complex gestures
- Don't forget about keyboard navigation

## Submitting Changes

### Before Submitting
1. Run `flutter analyze`
2. Run `dart format lib/`
3. Run all tests
4. Test on multiple devices
5. Check for console errors
6. Verify no sensitive data in code

### Submission Checklist
- [ ] Code follows style guidelines
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] All tests pass
- [ ] No console errors
- [ ] No sensitive data exposed
- [ ] Commit messages are clear

## Review Process

### What Reviewers Look For
- Code quality and style
- Architecture compliance
- Test coverage
- Documentation
- Performance impact
- Security implications
- User experience

### Addressing Feedback
- Respond to all comments
- Make requested changes
- Push updates to same branch
- Request re-review when ready
- Be open to suggestions

## Release Process

### Version Numbering
- Major.Minor.Patch (e.g., 1.0.0)
- Major: Breaking changes
- Minor: New features
- Patch: Bug fixes

### Release Checklist
- [ ] All tests pass
- [ ] Code reviewed
- [ ] Documentation updated
- [ ] Version bumped in `pubspec.yaml`
- [ ] CHANGELOG updated
- [ ] Build tested on all platforms
- [ ] Release notes prepared

## Questions?

- Check existing documentation
- Review similar code in project
- Ask in GitHub discussions
- Contact project maintainer

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (Proprietary).

---

Thank you for contributing to SIPEN-GO! 🎉

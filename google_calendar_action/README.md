# Google Calendar Action

![GitHub release (latest by date)](https://img.shields.io/github/v/release/TrueSelph/google_calendar_action)
![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/TrueSelph/google_calendar_action/test-google_calendar_action.yaml)
![GitHub issues](https://img.shields.io/github/issues/TrueSelph/google_calendar_action)
![GitHub pull requests](https://img.shields.io/github/issues-pr/TrueSelph/google_calendar_action)
![GitHub](https://img.shields.io/github/license/TrueSelph/google_calendar_action)

This action is designed to interface with the Google Calendar API allowing calendar data to be retrieved and calendar entries to be created. It provides the means to respond to Google Calendar updates via webhook. This action depends on version 2.0.0 of the Jivas library and requires several Python packages for its functionality, including `oauth2client`, `google-api-python-client`, and `google-auth`.

## Package Information

- **Name:** `jivas/google_calendar_action`
- **Author:** [V75 Inc.](https://v75inc.com/)
- **Architype:** `GoogleCalendarAction`
- **Version:** 0.0.1

## Meta Information

- **Title:** Google Calendar Action
- **Description:** Manages events and schedules on the specified Google Calendar.
- **Group:** core
- **Type:** action

## Configuration

- **Singleton:** true

## Dependencies

- **Jivas:** ^2.0.0
- **oauth2client:** 4.1.3
- **google-api-python-client:** 2.97.0
- **google-auth:** 2.32.0

---

### Best Practices

- Ensure your Google API credentials are valid and properly secured.
- Test calendar operations in a sandbox or testing environment to avoid accidental data changes.
- Review and manage Google API quotas to avoid service interruptions.

---

## 🔰 Contributing

- **🐛 [Report Issues](https://github.com/TrueSelph/google_calendar_action/issues)**: Submit bugs found or log feature requests for the `google_calendar_action` project.
- **💡 [Submit Pull Requests](https://github.com/TrueSelph/google_calendar_action/blob/main/CONTRIBUTING.md)**: Review open PRs, and submit your own PRs.

<details closed>
<summary>Contributing Guidelines</summary>

1. **Fork the Repository**: Start by forking the project repository to your GitHub account.
2. **Clone Locally**: Clone the forked repository to your local machine using a git client.
   ```sh
   git clone https://github.com/TrueSelph/google_calendar_action
   ```
3. **Create a New Branch**: Always work on a new branch, giving it a descriptive name.
   ```sh
   git checkout -b new-feature-x
   ```
4. **Make Your Changes**: Develop and test your changes locally.
5. **Commit Your Changes**: Commit with a clear message describing your updates.
   ```sh
   git commit -m 'Implemented new feature x.'
   ```
6. **Push to GitHub**: Push the changes to your forked repository.
   ```sh
   git push origin new-feature-x
   ```
7. **Submit a Pull Request**: Create a PR against the original project repository. Clearly describe the changes and their motivations.
8. **Review**: Once your PR is reviewed and approved, it will be merged into the main branch. Congratulations on your contribution!
</details>

<details open>
<summary>Contributor Graph</summary>
<br>
<p align="left">
    <a href="https://github.com/TrueSelph/google_calendar_action/graphs/contributors">
        <img src="https://contrib.rocks/image?repo=TrueSelph/google_calendar_action" />
   </a>
</p>
</details>

## 🎗 License

This project is protected under the Apache License 2.0. See [LICENSE](../LICENSE) for more information.
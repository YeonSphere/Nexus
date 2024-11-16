# Nexus Browser

## Important Update

We have shifted our focus to a new implementation to better serve our users. This README contains information about the current, actively developed version of Nexus Browser.

## Disclaimer

This browser is still in development and is not currently supported by official paid development teams. As a result, certain features may not work as expected up to 30% of the time or more. Please submit issues for bug fixes or feature requests, or join the Discord and contact @CEO or @founder to chat with the main developer and owner.

We appreciate your understanding and patience as we continue to improve the Nexus Browser.

## Discord Invite Link

https://discord.gg/uYJr9ZWQF4

## Overview

Nexus Browser is a modern web browser built with Flutter and Elixir. It allows users to browse the internet and access various websites. The browser includes features such as tab management, bookmarking, downloads, ad blocking, customizable settings, and a basic extension system.

(For inquiries about the specifics of ad blocking, please contact @daedaevibin)
(The ad blocking feature in Nexus Browser is designed in compliance with US federal laws. YeonSphere, its works, or members cannot be held liable for any conflicts with website-specific or company-specific terms of service regarding ad blocking. This browser and its features are not intended for use by Google, its affiliates, or any companies that restrict ad blocking, and cannot be considered in violation of their terms of service.)

## Structure

The repository is structured as follows:

- `lib`: Contains the source code for the Nexus Browser implementation.
- `frontend`: Contains the Flutter frontend code.
- `backend`: Contains the Elixir backend code.
- `assets`: Contains various resource files used by the browser.
- [README.md](README.md): This file, containing project information.

## Building

To build Nexus Browser:

1. Ensure you have Flutter and Elixir installed.
2. Clone the repository: `git clone https://github.com/YeonSphere/Nexus.git`
3. Navigate to the project directory: `cd Nexus`
4. For the frontend, navigate to the `frontend` directory and install dependencies: `cd frontend && flutter pub get`
5. For the backend, navigate to the `backend` directory and install dependencies: `cd backend && mix deps.get`
6. Build the project: 
   - For Flutter: `flutter build`
   - For Elixir: `mix phx.server`

## Contributing and Usage

Contributions are welcome! Please feel free to submit a Pull Request.

However, please note that redistribution, commercial use, or creating derivative works based on this software require explicit permission from @daedaevibin. To obtain permission, contact @daedaevibin via:

- GitHub: @daedaevibin
- Phone: +1 (208) 464-4061 (preferred method for faster response)
- Email: daedaevibin@naver.com

When contacting, please state your name and reason for use to avoid being mistaken for spam.

## Technology Stack

- Flutter: For cross-platform mobile and web application development
- Elixir: For the backend server
- Dart: For type-safe programming in Flutter
- Webview: For rendering web content
- HTTPoison: For making HTTP requests

## Features

The current implementation of Nexus Browser includes:

- Tab management
- Bookmarking
- Downloads manager
- Ad blocking (compliant with US federal laws)
- Customizable settings
- Basic extension system
- Cross-platform support (Windows, macOS, Linux)
- Developer tools

## Development Setup

1. Clone the repository: `git clone https://github.com/YeonSphere/Nexus.git`
2. Install dependencies for the frontend: `cd frontend && flutter pub get`
3. Install dependencies for the backend: `cd backend && mix deps.get`
4. Start the development server for the backend: `mix phx.server`
5. For the frontend, run: `flutter run`

## Contributing

We welcome contributions! Please read our [CONTRIBUTING.md](CONTRIBUTING.md) file for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under a custom license. See the [LICENSE](LICENSE) file for details.

## Contact

For any inquiries, please contact:
- GitHub: @daedaevibin
- Phone: +1 (208) 464-4061
- Email: daedaevibin@naver.com

## Acknowledgments

- All contributors and supporters of the Nexus Browser project

## Security

We take security seriously. If you discover a security vulnerability within Nexus Browser, please send an email to security@nexusbrowser.com. All security vulnerabilities will be promptly addressed.

## Roadmap

Our future plans for Nexus Browser include:

1. Improved performance and stability
2. Enhanced privacy features
3. More customization options
4. Expanded extension capabilities
5. Integration with decentralized technologies

Stay tuned for updates!

## Community

Join our growing community:

- Join our Discord server: [https://discord.gg/uYJr9ZWQF4](https://discord.gg/uYJr9ZWQF4)
- Check out our blog for the latest news and updates: [https://YeonSphere.github.io/blog/](https://YeonSphere.github.io/blog/)

We value your feedback and suggestions. Together, we can make Nexus Browser the best browsing experience possible!
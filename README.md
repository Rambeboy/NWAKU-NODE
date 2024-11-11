# Nwaku Node Auto Installation Script

This script automates the installation and management of a Nwaku node, making it easier to set up and maintain your node.

## Features

- 🚀 One-click installation
- 🔧 Automated configuration
- 🔐 Secure environment setup
- 📊 Storage management
- 🔄 Easy updates and maintenance
- 💻 Interactive CLI interface

## Prerequisites

- Ubuntu 20.04 or later
- 2vcpu (better with 4vcpu+)
- Minimum 2GB RAM
- At least 50GB free disk space
- Sepolia testnet RPC URL (e.g., from Infura)
- Testnet private key with some Sepolia ETH
- Sepolia faucet at least 0.6

## Quick Installation

Choose one of these methods to install:

### Method 1: Using curl

```bash
curl -fsSL https://raw.githubusercontent.com/Galkurta/Nwaku/main/nwaku.sh -o nwaku.sh && chmod +x nwaku.sh && sudo ./nwaku.sh
```

### Method 2: Using wget

```bash
wget https://raw.githubusercontent.com/Galkurta/Nwaku/main/nwaku.sh && chmod +x nwaku.sh && sudo ./nwaku.sh
```

## Installation Steps

The script provides an interactive menu with the following options:

1. **Install Prerequisites**

   - Updates system packages
   - Installs required dependencies
   - Configures firewall rules

2. **Install Docker**

   - Installs Docker and Docker Compose
   - Sets up Docker environment

3. **Install Nwaku Node**

   - Clones Nwaku repository
   - Configures environment settings
   - Sets up initial node configuration

4. **Register RLN Membership**

   - Optional step for message relay capabilities
   - Requires Sepolia ETH for staking

5. **Set Storage Allocation**

   - Configure node storage settings
   - Set retention policies

6. **Start Nwaku Node**
   - Launches the node using Docker Compose
   - Displays real-time logs

## Configuration

During installation, you'll need to provide:

- Sepolia RPC URL
- Private key (without 0x prefix)
- RLN membership password (min. 8 characters)

Optional advanced settings:

- Custom Nwaku image
- Node key
- Domain
- Extra arguments
- Storage size

## Management Commands

### Update Node

```bash
# Select option 7 from menu
```

### Restart Node

```bash
# Select option 8 from menu
```

### Shutdown Node

```bash
# Select option 9 from menu
```

### Delete Node

```bash
# Select option 10 from menu
```

## Testing Your Node

### Send Test Message

```bash
curl -X POST "http://127.0.0.1:8645/relay/v1/auto/messages" \
 -H "content-type: application/json" \
 -d '{"payload":"'$(echo -n "Hello Waku Network - from Anonymous User" | base64)'","contentTopic":"/my-app/2/chatroom-1/proto"}'
```

### Get Messages

```bash
curl -X GET "http://127.0.0.1:8645/store/v1/messages?contentTopics=%2Fmy-app%2F2%2Fchatroom-1%2Fproto&pageSize=50&ascending=true" \
 -H "accept: application/json"
```

### Check Node Version

```bash
curl http://127.0.0.1:8645/debug/v1/version
```

### Check Node Info

```bash
curl http://127.0.0.1:8645/debug/v1/info
```

## Troubleshooting

### Common Issues

1. **Docker Installation Fails**

   - Ensure your system meets the prerequisites
   - Check internet connectivity
   - Try running `sudo apt update` before installation

2. **RLN Registration Fails**

   - Verify you have sufficient Sepolia ETH
   - Check your RPC URL is valid
   - Ensure private key is entered correctly

3. **Node Won't Start**
   - Check Docker service is running
   - Verify port availability
   - Check logs using `docker-compose logs -f nwaku`

### Support

If you encounter any issues:

1. Check the logs
2. Refer to [Nwaku Documentation](https://docs.waku.org/)
3. Open an issue on GitHub
4. Join the Waku community Discord

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Security

- Never share your private keys
- Keep your RLN membership password secure
- Regularly update your node
- Monitor your node's performance and logs

## Acknowledgements

- Waku Protocol Team
- Docker
- The entire Status Network community

## Contact

- Author: Galkurta
- GitHub: [@Galkurta](https://github.com/Galkurta)

## Disclaimer

This is an unofficial installation script. Use at your own risk. Always verify the source and content of scripts before running them on your system.

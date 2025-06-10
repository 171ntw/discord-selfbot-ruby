# Discord SelfBot Ruby

## Description
*This Ruby selfbot provides a powerful and efficient way to automate your interactions and manage your own Discord account. Designed for personal use, it allows you to execute repetitive tasks or customize your user experience with direct commands, bringing more control and convenience to your Discord activity.*

### Functions

- Clear (DM/CHANNEL) | `🟢`
- Upcoming Features | `🟡`

### Git Clone

```bash
git clone https://github.com/171ntw/discord-selfbot.rb.git
cd discord-self-bot
```

### Install Dependencies

```bash
bundle install
```

### Self Token
*Before running the selfbot, you need to configure your Discord user token.*
1. **Create a `.env` file in the root directory of the project (the same place as `main.rb`).**
2. **Add your Discord token** to this file in the following format:
```
token=YOUR_DISCORD_USER_TOKEN_HERE
```
**Replace** `YOUR_DISCORD_USER_TOKEN_HERE` with your actual Discord user token.
**Note**: *Your Discord user token is highly sensitive. Keep it private and never share it publicly.*

### Run Self

```bash
ruby main.rb
```
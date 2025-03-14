# GameChat
GameChat is an iOS app created to solve the problem of trying to communicate about a sports game to people who are watching elsewhere. In the days of streaming, everyone seems to be watching a different way. You can be ahead or behind the rest of the group. On a big play, you want to text your buddies about it, but if your stream is ahead of theirs, you'd spoil the play. When I've been watching on a stream that's behind, I only check the group's messages during commercials so as not to have any plays spoiled. To solve this, GameChat allows users to calibrate their devices so they only see messages about plays that have happened on their own stream. It also sorts the messages by when in the game they were sent so the users that are ahead will see the chronological order of the messages. 

## Walkthrough 
Initially opening the app, users are asked to sign up/log in. 

<p align="center">
<img src="https://github.com/user-attachments/assets/bf7b427d-0334-4bf4-a02d-ec9c795e65be" width="200">
</p>
After completing that, users will be on the [ChatPageView](https://github.com/dshel9/GameChat/blob/main/Client/GameChat/GameChat/Views/Chat/ChatPageView.swift), which shows all the rooms a user is in. 

{Chat page view example no rooms} {Chat page view example with room}

Users can click the plus in the top right of the screen to create or join a room on the [CreateOrJoinRoomView](https://github.com/dshel9/GameChat/blob/main/Client/GameChat/GameChat/Views/CreateOrJoinRoomView.swift). 

{CreaeOrJoinRoomView picture }

Once a room is selected, users will see the [ChatView](https://github.com/dshel9/GameChat/blob/main/Client/GameChat/GameChat/Views/Chat/ChatView.swift). In the top right of the screen, users have three options. The first option is to share the room, which allows user to share the room ID. The second option is to leave the room. And the third option is to create a calibration. 

{ChatView empty}

If the user clicks on the create a calibration option, they will see the [CreateACalibrationView](https://github.com/dshel9/GameChat/blob/main/Client/GameChat/GameChat/Views/Chat/CreateCalibrationView.swift), which gives them the option to create a calibration event. 

{Creat a calibrationview picture}

When other users join or leave the room, a message will be sent from ChatManager, informing the remaining users. 

{Chat page with chats and calibrations}

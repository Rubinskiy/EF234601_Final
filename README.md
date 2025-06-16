<p align="center"><b>Mobile Programming (2025)</b><br>Sepuluh Nopember Institute of Technology</p>

<p align="center"><img src="https://raw.githubusercontent.com/Rubinskiy/IF184202-Data-Structures/main/its.png" style="transform: scale(0.5);"></p>
  
<p align="center">Source code to Final Project Flutter App that was created for <a href="https://www.its.ac.id/informatika/wp-content/uploads/sites/44/2023/11/Module-Handbook-Bachelor-of-Informatics-Program-ITS.pdf">EF234601</a>.</p>
<p align="center">All solutions were created by <a href="https://github.com/Rubinskiy">Robin</a>, <a href="https://github.com/parisyaputri">Parisya</a>, and <a href="https://github.com/Argreion">Zhafir</a></p>

<hr>

# Overview
Our final project idea is a Campus Event Tracker app. Students can view events across campus, register for them, and manage campus events. However, we prefer to stick to the baseline requirements of our Mobile Programming class, and some features like those of "manage campus events" requires a backend component to manage them too, which is out of the scope of this project. Therefore, we limit this backend aspect (not entirely) and stick to our frontend code more.

## Week 1
Week 1 is dedicated to preliminary research on what our ideas are for the app and what it should look like. Since this is a Mobile Programming class, and not a UI/UX design class, we assume the use of AI design tools such as Google Stitch would not affect our final score.

![image](https://github.com/user-attachments/assets/3dc6620d-0ae2-4037-9232-b5418e6da738)

These generated designs are purely for inspiration to mimic on our app. View the Figma workspace [here](https://www.figma.com/design/DRmUTiWiIoZE97fiyTUSqu/Final-Project-Flutter-App?node-id=0-1&t=GTDP0aoBmJbs5yOo-1).

## Week 2
Week 2 we started the development of the app and created the basic structure (auth using Firebase), implementation of UI from Figma.

<img src="https://github.com/user-attachments/assets/0558f898-2fe6-40dc-a232-45c70fff4fbc" width="300" />

<img src="https://github.com/user-attachments/assets/7890bb84-9b8e-453a-8880-5693ff333cb8" width="300" />


## Week 3
Week 3 is where we added Firestore to create our collection of events, and used CRUD to create them, display and delete. We also added the ability to edit events and add images which we store on a third-party image storage service called Cloudinary. At this point we have completed half of the screens and functionality of the app. We stuck with a very minimalistic design and is not entirely aligned with the UI from Figma, regardless, we think the functionality is far more important.

<img src="https://github.com/user-attachments/assets/95f4707a-b73d-405f-b1a1-6d3ea4ec8163" width="300" />

<img src="https://github.com/user-attachments/assets/ac6516ad-3c00-4b06-81b5-18d33d847a2f" width="300" />

<img src="https://github.com/user-attachments/assets/426a8728-30ef-471e-a59e-0a27fbcb755a" width="300" />

## Week 4
Week 4 is where we finalized the app, added the ability to register for events, and display them in a list. We updated our Firestore database to have about 3 documents and number of collections inside of them used for "events", "users", and "registrations". The app is now fully functional and ready for submission. For our CI/CD the reason why we didn't include a build for Android and iOS is that the build time takes > 5 minutes, which might delay us from making a quick pull request.

<img src="https://github.com/user-attachments/assets/9302d501-4940-4182-af44-2c0acb7b2b8a" width="300" />

<img src="https://github.com/user-attachments/assets/9e65abb8-1d60-4a3a-a3ee-734b24000364" width="300" />

## Contribution
All code was written by the three of us, and we used GitHub to manage our code. We also used GitHub Issues to track our progress and tasks.

**Robin**:
- Created initial structure of the app
- CRUD for registrations
- Setup Firebase, Firestore
- Cloudinary integration
- CI/CD for test and analyze

**Parisya**: 
- Created the UI
- Firebase Auth
- Firestore integration
- CRUD for events
- Crashlytics
- OSM API

**Zhafir**: 
- Created the UI
- Firestore integration
- CRUD for user profile
- Splash screen

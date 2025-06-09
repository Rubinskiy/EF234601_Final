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
Week 2 we started the development of the app and created the basic structure (auth using Firebase), implementation of UI from Figma

## Week 3
Week 3 is where we added Firestore to create our collection of events, and used CRUD to create them, display and delete. We also added the ability to edit events and add images which we store on a third-party S3-compatible platform called tebi.io.
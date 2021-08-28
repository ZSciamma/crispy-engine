# CS A Level Project

This project was completed during the 2017-18 school year as coursework for the UK Computer Science AQA A Level. It also included a 120-page technical specification with research, analysis, and testing. Furthermore, the project had to be discuess with an end-user, who helped guide the features and provided expertise to get the most out of the idea. Overall, the project scored 71/75 in the course.

## Components

This repository is the Student App component of the project. There are two other components:

* The Teacher App: [ZSciamma/fuzzy-guacamole](https://github.com/ZSciamma/fuzzy-guacamole)
* The Server App: [ZSciamma/super-duper-doodle](https://github.com/ZSciamma/super-duper-doodle)

## Overview

The project aims to teach music students interval recognition. The app involves short quizzes which test a student's ability to identify various musical intervals. For example, if the app plays a minor third, the student must click the minor third button before a timer elapses; they will then get a score depending on the speed of their answer. 

## Development

The app was entirely built in Lua, using the LÖVE framework. 

The project had a complexity requirement, which I chose to complete by implementing many different features completely from scratch. I found it interesting to write the whole project using only very basic Lua libraries, and I learnt a lot through this process. So, the user interface is built entirely from scratch in Lua, as are all the data structures (graphs, linked lists etc), the relational database implementation, and the client-server networking between the various apps.

## Features

As part of the complexity requirement for the course, the project has the following features:
* Learning model: As the student improves, the app's quizzes become more difficult. As the student gains levels, they increase the range of intervals available. The app thus starts with only the easiest intervals, then progresses to the more difficult ones. It also uses the [Leitner system](https://en.wikipedia.org/wiki/Leitner_system) to space out the repetition of questions and thus attempt to improve the efficiency of the learning.
* Classes: using the Teacher app, teachers can create classes for their students. Students can join a class from their student app, and teachers can have multiple classes
* Tournaments: Teachers can run tournaments for their classes. In these tournaments, students compete against each other for the best scores. At the end, the teacher can see class results on their app. The tournaments run a Swiss tournament algorithm to determine the matches of students. The graph data structures and traversal algorithms needed are built from scratch in Lua.
* Server: a central server app allows the teacher and student classes to communicate with each other. This app contains a database which stores class information and tournament scores, so that teachers and students can log in from any device and the app will receive the user's information. This database is custom built from scratch and mimics a normalized relational database in Lua.
* Networking: In order to communicate between the apps, the project uses a client-server model. It is built from Lua's lightweight [Enet library](https://leafo.net/lua-enet/). I wrote a system for defining the various allowed messages, passing messages between the apps, and delimiting between messages.

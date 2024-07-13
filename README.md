# FashionAI

FashionAI is an IOS app that was built to solve my lack of fashion in a clothing sense. Inspired by my tardiness to work one day and leaving a pile of clothes on my bed, I decided to solve for the issue by developing an AI based app. Here is how it works:

 - After registering their account on the app, users are able to upload/take pictures of their closet and clothes which get stored in a database viewable in the "Profile" section of the app. Note: the user is able to add as many as they want and have the option to delete any unwanted images.
 - Users can upload their chosen images to gpt4o's chat system that is trained on a select document highlighting different sections of fashion and color combinations.
 - Users can then have their response tailored for a specific event by simply prompting the chatbot for a certain event. An example can include: "Based off the images of my clothes, can you suggest an outfit that I can wear to a downtown party?"


### Technologies Used

- SwiftUI using XCode (frontend work)
- Firebase (backend database, authentification, storage)
- Python (RAG pipeline)
- GPT4o's API (for the AI. **Note that if you want to use this app for personal purposes, you will have to get an API key, create a config file, and add that key once cloned.**)


### Getting Started

If you want to try this out for yourself, follow these steps!

1. Clone the repo and open in XCode
   
   `git clone https://github.com/aashishdhanani/AIFashion.git`

3. Add your API key to a config file (won't be able to use the app without it!)

4. Either plug in your phone to your laptop, or run on a simulator (personal phone recommended)

5. Thats all! Enjoy FashionAI

### Extra resources

- [OpenAI](https://platform.openai.com/docs/api-reference/introduction)
- [SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/)
- [Firebase Tutorial](https://firebase.google.com/docs)
- [RAG Pipeline Tutorial](https://www.youtube.com/watch?v=6D9mpFCPeI8)

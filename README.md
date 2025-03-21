# Face Condition Detection in Any Lighting
![Static Badge](https://img.shields.io/badge/GSoC'25%20Qualification%20Task-8A2BE2)

This flutter app detects the emotions of all the people in the camera frame. It uses ***GetX*** state management for efficiency, and simplicity.

Under the hood, there is a TensorFlow's [tflite](https://www.tensorflow.org/api_docs/python/tf/lite) model running inference and giving out the probability for the following emotions:
- Neutral
- Happy
- Angry
- Sad
- Surprised
- Fearful
- Disgusted


You can find the dataset that I used for training the model [here](https://www.kaggle.com/datasets/ananthu017/emotion-detection-fer).

And the Python notebook that did all the image preprocessing, feature extraction, training, etc. [here](https://colab.research.google.com/drive/1EgQFpVPb5ZIXg8QftuEbKk1zU9g_QLr1?usp=sharing)

## ScreenRecordings
for iOS


https://github.com/user-attachments/assets/31595d7f-a201-45e1-8fe9-608db1790c35



for Android



https://github.com/user-attachments/assets/3c388335-833a-4166-84c2-00a41f42ac25



### It can also detect multiple faces:


https://github.com/user-attachments/assets/bd7b6e58-6770-4018-8803-6263887f11a1

### Brightness Detection
Since the model was trained with all kinds of lighting conditions, it can detect emotions even in dim light. Nevertheless, there is still a prompt for `too dim` and `too bright` lighting.

![Screenshot 2025-03-21 at 8 31 33 PM](https://github.com/user-attachments/assets/c0983e57-c33d-417b-ab2d-72bbd89b66de)


### Packages used
- camera
- get
- google_mlkit_face_detection
- tflite_flutter
- image
- collection

## Running locally
for Android
```
git clone https://github.com/kushchoudhary98/flutter_emotion_detection.git
cd flutter_emotion_detection
flutter pub get
flutter run
```

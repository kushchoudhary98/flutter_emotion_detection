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

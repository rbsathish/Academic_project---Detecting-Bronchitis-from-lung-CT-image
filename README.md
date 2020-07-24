#Detecting Bronchitis from lung CT image

A Computer-aided diagnosis(CAD) system is proposed to detect the presence of bronchitis from  lung CT images.
The CT image of lungs is preprocessed and optimal thresholding based segmentation is done to obtain the lung as a binary image.
ROIs are segmented based on the pixels intensity from which the features are extracted. Texture features and geometric features
were extracted to form a feature vector from each ROI.  Using hybrid Ant colony optimization to select the features from the feature
vector and classify the selected features using SVM classifier with tenfold cross validation. Training and Testing is done and the performance measure evaluated.

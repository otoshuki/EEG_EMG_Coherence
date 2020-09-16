# Hybrid BCI System
## This project was done as my 2nd year summer research intern
### Only the programs I worked on has been added here.
### The work on KPLS and KPLS-mRMR hasn't been added since I didn't create it or hold the rights.

The project was on developing a hybrid BCI system that uses both EEG and EMG signals for classifying forearm state(open or closed). This information would've been used as a control signal for a bionic arm.

Motor imagery can be defined as the act/state of mentally simulating a physical action. In the case of stroke patients or the ones with forelimbs loss this is often the best "heuristic" for identifying forelimbs movement intent. But EEG signal based classification are often inaccurate, due to the highly complex nature of the brain wrt the very low dimensions of data we can use and also due to the noise from motion, hair and other body parts.

EMG signals on the other hand(pun intended), are attached directly to the hands just over the required muscles to extract electrical signals. This is often less noisy and more accurate for real motion, but can be highly prone to errors in motor imagery. A combination of both measures can be done to have better classification accuracies has been worked upon by several research groups over the years [1-7].

## The Work

The first step was on understanding the brain and its connection to the muscles. The basic biological theory was already known but the mathematical and signal processing based reasoning had to be learned. A book I didn't document well and thus forgotten the name of, was used for this.

I worked with a dataset containing 64 channel EEG + 4 channel EMG data over several trials taken from 52 subjects [8]. The dataset had both real movement data and motor imagery data over the complete 68 channels which was pre labelled and cleaned. The EEG data followed international 10-10 system, while the EMG channels were attached to flexor digitorium profundus and extensor digitorium on each arm

Different frequency bands of the EEG data (delta, theta, alpha, beta and gamma) relates to different brain activations corresponding to different activities [9]. Also different regions of the brain are activated during different activities, specifically motor cortex region during movement tasks and motor imagery [10]. This greatly reduces the number of channels highly correlated to motor imagery activations to about 10 EEG channels.

[11,12] provided insights into the current feature extraction algorithms used for individual EEG and EMG signals, but most of the work shifted towards coherence estimation based on A. Choudary's works [1,2,3]. Several different attempts on improving the provided systems were tried and tested with different machine learning models and dimensionality reduction methods like PCA and mainly KPLS-mRMR [13] which is a feature selection method based on minimum Redundancy Maximum Relevance selection over Kernel based PLS(partial least squares) coeficients[14].

## Okay, the actual work

1. I finally ended up with 10 EEG channels and 4 EMG channel data from 52 subjects. This included both motor imagery and real movement data. The data was sampled at 512 Hz and each trial ran for about 5s. 
2. First step was the set up the data as a training set, i.e. with features and labels. Luckily, the data was already sorted into left and right movement/motor imagery cases and all the trials were concatenated. It also had a binary label indicating the onset of each event. During most of my tests I took 2s from the trial as the training sample.
3. But wait, isn't the entire dataset only positive classes? They are indeed, so the only way I could get negative samples was to sample it out from the trial data. This selection of positive and negative classes differed from algorithm to algorithm. 
4. In cases when I only wanted to classify the present condition of the subject, I'd sample ~1.5-2s from the initial rest state as negative class and ~1.5-2s after the onset as positive class. In cases when I wanted to check the coherence structure I'd take 1s before the onset and 1s into the event as the positive class while I take 2s after the selection as the negative class.
5. Also, in my work I tried classifying left and right hand movement intent; in this case the data was easy to collect. 2-3s from right movement as positive and that from left movement as negative.
6. Honestly a lot of work went into studying and reading about this completely new field I pushed myself into.
7. Some of the features I used from current literature were - 
  - Correlation between band-limited power time-courses(CBPT) [3]
  - Corticomuscular-Coherence(CMC) [1]
  - Task-related EEG power increase(TRPI) [6]
  - Spectral power correlation(SPC) [2]
  - Discrete fourier transform(FT) coefficients
  - Short time fourier transform(STFT) coefficients [11]
  - Discrete wavelet transform(DWT) coefficients [11]
  - Power spectral density(PSD) [12]
  - Spectral magnitude averages [12]
  - The last one I tried was called S-transform (not the same as Laplace transform), which ended up not working at all.
10. Also, as [9] shows, different frequency bands were analyzed for different coherence structures. Discrete time band pass filters did the job anyway.
9. Used KPLS-mRMR from [13] to perform feature selection, which essentially performs Kernel based Partial Least Squares Regression and uses these coefficients to calculate a relevance score between two features. This is then used to select the best features as given in the paper. Part of this was also implemented in the process while the code for KPLS regression can be found online. 
10. After a lot of feature extraction-selection, Statistics and ML toolbox comes to the rescue enabling training of several different algorithms using the training set including k-fold cross validation. Data visualization lost hope since a lot of the features didn't show visible patterns anyway.
11. PCA was also used on the data before feeding into the algorithms. The performances were recorded and for the ones that showed hope, I performed it again separately while tuning the parameters to get err... better performance.
12. Some of the features-model pairs showed high classification accuracies and were recorded.

## References - 

1. A. Chwodhury, H. Raza, A. Dutta, S. S. Nishad, A. Saxena and G. Prasad, "A study on cortico-muscular coupling in finger motions for exoskeleton assisted neuro-rehabilitation," 2015 37th Annual International Conference of the IEEE Engineering in Medicine and Biology Society (EMBC), Milan, 2015, pp. 4610-4614, doi: 10.1109/EMBC.2015.7319421.

2. Anirban Chowdhury, Haider Raza, Ashish Dutta, and Girijesh Prasad. 2017. EEG-EMG based Hybrid Brain Computer Interface for Triggering Hand Exoskeleton for Neuro-Rehabilitation. In Proceedings of the Advances in Robotics (AIR '17). Association for Computing Machinery, New York, NY, USA, Article 45, 1–6. DOI:https://doi.org/10.1145/3132446.3134909

3. Chowdhury, Anirban & Raza, Haider & Meena, Yogesh & Dutta, Ashish & Prasad, Girijesh. (2018). An EEG-EMG Correlation-based Brain-Computer Interface for Hand Orthosis Supported Neuro-Rehabilitation. Journal of Neuroscience Methods. 312. 10.1016/j.jneumeth.2018.11.010. 

4. Gao Y, Ren L, Li R and Zhang Y (2018) Electroencephalogram–Electromyography Coupling Analysis in Stroke Based on Symbolic Transfer Entropy. Front. Neurol. 8:716. doi: 10.3389/fneur.2017.00716

5. Lou, Xinxin & Xiao, Siyuan & Qi, Yu & Hu, Xiaoling & Wang, Yiwen & Zheng, Xiaoxiang. (2013). Corticomuscular Coherence Analysis on Hand Movement Distinction for Active Rehabilitation. Computational and mathematical methods in medicine. 2013. 908591. 10.1155/2013/908591. 

6. Hashimoto, Yasunari & Ushiba, Junichi & Kimura, Akio & Liu, Meigen & Tomita, Yukata. (2010). Correlation between EEG-EMG coherence during isometric contraction and its imaginary execution. Acta neurobiologiae experimentalis. 70. 76-85. 

7. Severini, Giacomo & Conforto, Silvia & Schmid, Maurizio & D'Alessio, Tommaso. (2012). A Multivariate Auto-Regressive Method to Estimate Cortico-Muscular Coherence for the Detection of Movement Intent. Applied Bionics and Biomechanics. 9. 135-143. 10.3233/ABB-2011-0036. 

8. Hohyun Cho, Minkyu Ahn, Sangtae Ahn, Moonyoung Kwon, Sung Chan Jun, EEG datasets for motor imagery brain–computer interface, GigaScience, Volume 6, Issue 7, July 2017, gix034, https://doi.org/10.1093/gigascience/gix034

9. Hema, C.R. & M P, Paulraj & Yaacob, Sazali & Adom, Abdul & Nagarajan, R. (2010). An Analysis of the Effect of EEG Frequency Bands on the Classification of Motor Imagery Signals. Biomedical Soft Computing and Human Sciences. 16. 121-126. 

10. Alyssa M. Batula, Jesse A. Mark, Youngmoo E. Kim, Hasan Ayaz, "Comparison of Brain Activation during Motor Imagery and Motor Movement Using fNIRS", Computational Intelligence and Neuroscience, vol. 2017, Article ID 5491296, 12 pages, 2017. https://doi.org/10.1155/2017/5491296

11. Subha, D.P., Joseph, P.K., Acharya U, R. et al. EEG Signal Analysis: A Survey. J Med Syst 34, 195–212 (2010). https://doi.org/10.1007/s10916-008-9231-z

12. Sharma, Sachin & Kumar, Gaurav & Kumar, Sandeep & Mohapatra, Debasis. (2012). Techniques for Feature Extraction from EMG Signal. International Journal of Advanced Research in Computer Science and Software Engineering. 2. 

13. Talukdar, Upasana & Hazarika, Shyamanta & Gan, John. (2018). A Kernel Partial Least Square Based Feature Selection Method. Pattern Recognition. 83. 10.1016/j.patcog.2018.05.012. 

14. Rosipal, Roman. (2003). Kernel Partial Least Squares for Nonlinear Regression and Discrimination. Neural Network World. 13. 291-300. 


# coding: utf-8

# In[76]:

import os
from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import wordcloud

f = path.dirname("/Users/Macbook/myProjects/")


# Read the whole text.
text = open(path.join(f, 'breweries.txt')).read()

# read the mask image
alice_mask = np.array(Image.open(path.join(f, "c.jpg")))

stopwords = set(STOPWORDS)
stopwords.add("Brewery")

wc = WordCloud(font_path='/Users/Macbook/Library/Fonts/AdobeGaramondProRegular.ttf',
               background_color="black",
               max_words=50000,
               max_font_size=100,
               mask=alice_mask,
               stopwords=stopwords,
               width=1600, height=800)
# generate word cloud
wc.generate(text)

# store to file
wc.to_file(path.join(f, "Beer-Bottle-Stencil-thumb.jpg"))

# show
plt.imshow(wc, interpolation='bilinear')
plt.axis("off")
plt.figure( figsize=(20,10) )
plt.imshow(alice_mask, cmap=plt.cm.gray, interpolation='bilinear')
plt.axis("off")
plt.show()


# In[ ]:





import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.decomposition import PCA

# Load data
listings = pd.read_csv("clean_listings.csv")
calendar = pd.read_csv("clean_calendar.csv")

# EDA: Price distribution
sns.histplot(listings['price'], bins=50)
plt.title("Listing Price Distribution")
plt.show()

# Regression
df = listings[['price', 'room_type', 'minimum_nights', 'number_of_reviews',
               'reviews_per_month', 'availability_365']].dropna()
df = df[df['price'] < 1000]
df = pd.get_dummies(df, columns=['room_type'], drop_first=True)
X = df.drop('price', axis=1)
y = df['price']
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
model = LinearRegression()
model.fit(X_train, y_train)
preds = model.predict(X_test)
print("RMSE:", mean_squared_error(y_test, preds, squared=False))

# Clustering
features = ['price', 'minimum_nights', 'number_of_reviews', 'availability_365']
cluster_df = listings[features].dropna()
cluster_df = cluster_df[cluster_df['price'] < 1000]
scaler = StandardScaler()
X_scaled = scaler.fit_transform(cluster_df)
kmeans = KMeans(n_clusters=4, random_state=0)
clusters = kmeans.fit_predict(X_scaled)
pca = PCA(n_components=2)
components = pca.fit_transform(X_scaled)
plt.scatter(components[:, 0], components[:, 1], c=clusters, cmap='rainbow')
plt.title("KMeans Clustering of Listings")
plt.show()

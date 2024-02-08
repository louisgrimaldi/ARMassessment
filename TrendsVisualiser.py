from typing import List, Optional
import pandas as pd
from pytrends.request import TrendReq
import seaborn as sns
import matplotlib.pyplot as plt
import unittest


class ShareOfSearchVisualizer:
    def __init__(self, search_terms: List[str], timeframe: Optional[str] = 'today 3-m') -> None:
        self.search_terms = search_terms
        self.timeframe = timeframe
        self.pytrends = TrendReq(hl='en-UK', tz=360)  # Note: "Football" may be skewed by US-based results
        # regarding American Football. That could be intentional however, so we keep it as is instead of locking the region to Europe, for example.
        self.data = None

    def fetch_data(self):
        self.pytrends.build_payload(self.search_terms, timeframe=self.timeframe)
        interest_over_time_df = self.pytrends.interest_over_time()
        self.data = interest_over_time_df.div(interest_over_time_df.sum(axis=1), axis=0) * 100

    def visualize(self):
        if self.data is None:
            self.fetch_data()

        plt.figure(figsize=(10, 6))
        sns.set(style='darkgrid')
        for term in self.search_terms:
            sns.lineplot(data=self.data[term], label=term)

        plt.title('Share of Search Over the Past 3 Months')
        plt.xlabel('Date')
        plt.ylabel('Share of Search (%)')
        plt.legend()
        plt.xticks(rotation=45)
        plt.tight_layout()
        plt.show()


class TestShareOfSearchVisualizerUnit(unittest.TestCase):
    def setUp(self):
        self.search_terms = ['Football', 'Rugby', 'Tennis']
        self.share_of_search_visualizer = ShareOfSearchVisualizer(self.search_terms)

    def test_fetch_data(self):
        self.share_of_search_visualizer.fetch_data()
        self.assertIsNotNone(self.share_of_search_visualizer.data)

    def test_fetch_data_invalid_terms(self):
        invalid_search_terms = ['InvalidTerm1', 'InvalidTerm2']
        invalid_share_of_search_visualizer = ShareOfSearchVisualizer(invalid_search_terms)
        invalid_share_of_search_visualizer.fetch_data()
        self.assertTrue(invalid_share_of_search_visualizer.data.empty)


if __name__ == "__main__":

    # Run the graph visualiser, then print test results. Can also run coverage if needed
    search_terms = ['Football', 'Rugby', 'Tennis']
    share_of_search_visualizer = ShareOfSearchVisualizer(search_terms)
    share_of_search_visualizer.visualize()

    unittest.main()

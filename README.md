# Neo4j Graph Database Assignment

Assignment 2 for the Mining Big Datasets Course of AUEB's MSc in Business Analytics.

### Dataset
You are provided with a subset of the high energy physics theory citation network, comprising authors, articles, journals, and citations between articles. The dataset contains:
- 29,555 articles with id, title, year, journal, and abstract
- 15,420 authors with names
- 836 journals with names
- 352,807 citations among papers
You can download the dataset (Citation Dataset) from moodle in CSV format. The dataset files include:
- **ArticleNodes.csv**: Information about Article nodes (id, title, year, journal, and abstract).
- **AuthorNodes.csv**: Article id and the name of the author(s).
- **Citations.csv**: Information about citations between articles (articleId,--[Cites]->, articleId).

### Property Graph Model
Model the data as a property graph by designing the appropriate entities and assigning the relevant labels, types, and properties. Include attributes that describe each node and edge type without repetitions. Ensure nodes are connected only when necessary.

### Importing the Dataset into Neo4j
Create a graph database on Neo4j and load the citation network elements using the provided CSV files. You can load the dataset directly from the CSV files using the Neo4j browser, Neo4j import tool, or any supported programming language. Consider creating proper indexes on your model properties to improve loading and query response times.

### Querying the Database
Execute the following queries using the Cypher language:

1. Identify the top 5 authors with the most citations from other papers.
2. Determine the top 5 authors with the most collaborations with different authors.
3. Find the author who has written the most papers without collaborations.
4. Discover the author who published the most papers in 2001.
5. Identify the journal with the most papers about "gravity" in 1998.
6. Find the top 5 papers with the most citations.
7. Retrieve papers that mention both "holography" and "anti de sitter" in the abstract.
8. Find the shortest path between two authors ('C.N. Pope' and 'M. Schweda').
9. Repeat the previous query but only using edges between authors and papers.
10. Find all authors with shortest path lengths > 25 from author 'Edward Witten' considering only edges between authors and articles.

### Assignment Handout
Your deliverable should include:
1. **Report.pdf**:
   - Detailed graph model description.
   - Commands used for importing files to the database.
   - Cypher code for required queries with results.
2. **Program/Script**: Implementations for any step of the assignment.
3. **queries.cy**: A text file containing the queries expressed in Cypher language.

// DATASET: verify how LOAD CSV sees the data

// Count data rows in ArticleNodes.csv (no headers)
LOAD CSV FROM 'file:///ArticleNodes.csv' AS row
RETURN COUNT(row);

// Count data rows in AuthorNodes.csv (no headers)
LOAD CSV FROM 'file:///AuthorNodes.csv' AS row
RETURN COUNT(row);

// View data rows in Citations.csv
LOAD CSV FROM 'file:///Citations.csv' AS row
FIELDTERMINATOR '\t'
RETURN row
LIMIT 3;

// Change data types and view top 3 data rows in ArticleNodes.csv
LOAD CSV FROM 'file:///ArticleNodes.csv' AS row
WITH toInteger(row[0]) AS articleId, trim(row[1]) AS articleTitle, toInteger(row[2]) AS articleYear, trim(row[3]) as articleJournal, trim(row[4]) as articleAbstract 
RETURN articleId, articleTitle, articleYear, articleJournal, articleAbstract
LIMIT 3;

// Change data types and view top 3 data rows in AuthorNodes.csv
LOAD CSV FROM 'file:///AuthorNodes.csv' AS row
WITH toInteger(row[0]) AS articleId, trim(row[1]) AS authorName 
RETURN articleId, authorName
LIMIT 3;

// Change data types and view top 3 data rows in Citations.csv
LOAD CSV FROM 'file:///Citations.csv' AS row
FIELDTERMINATOR '\t'
WITH toInteger(row[0]) AS articleId, toInteger(row[1]) AS articleCitation 
RETURN articleId, articleCitation
LIMIT 3;


// GRAPH DATA MODEL CONSTRAINTS AND INDEXES

// Author's unique name property
CREATE CONSTRAINT authorNameConstraint FOR (au:Author) REQUIRE au.name IS UNIQUE;

// Article's unique id property and index on title property
CREATE CONSTRAINT articleIdConstraint FOR (ar:Article) REQUIRE ar.id IS UNIQUE;
CREATE INDEX FOR (ar:Article) ON (ar.title);

// Journal's unique name property
CREATE CONSTRAINT journalNameConstraint FOR (j:Journal) REQUIRE j.name IS UNIQUE;


// IMPORT DATA USING "LOAD CSV"

// Import from ArticleNodes.csv
// Faster (1482 ms)
LOAD CSV FROM 'file:///ArticleNodes.csv' AS row
WITH toInteger(row[0]) AS articleId, trim(row[1]) AS articleTitle, toInteger(row[2]) AS articleYear, trim(row[3]) as articleJournal, trim(row[4]) as articleAbstract 
CREATE (ar:Article {id: articleId, title: articleTitle, year: articleYear, abstract: articleAbstract})
FOREACH (
x IN CASE WHEN articleJournal IS NULL THEN [] ELSE [1] END |
	MERGE (j:Journal {name: articleJournal})
	CREATE (ar)-[:IS_PUBLISHED]->(j)
);
// Slower (1185 + 443 = 1628 ms)
//LOAD CSV FROM 'file:///ArticleNodes.csv' AS row
//WITH toInteger(row[0]) AS articleId, trim(row[1]) AS articleTitle, toInteger(row[2]) AS articleYear, trim(row[3]) as articleJournal, trim(row[4]) as articleAbstract
//WHERE articleJournal IS NOT NULL
//MERGE (j:Journal {name: articleJournal})
//CREATE (ar:Article {id: articleId, title: articleTitle, year: articleYear, abstract: articleAbstract})
//CREATE (ar)-[:IS_PUBLISHED]->(j);
//LOAD CSV FROM 'file:///ArticleNodes.csv' AS row
//WITH toInteger(row[0]) AS articleId, trim(row[1]) AS articleTitle, toInteger(row[2]) AS articleYear, trim(row[3]) as articleJournal, trim(row[4]) as articleAbstract
//WHERE articleJournal IS NULL
//CREATE (ar:Article {id: articleId, title: articleTitle, year: articleYear, abstract: articleAbstract});

// Import from AuthorNodes.csv (1386 ms)
LOAD CSV FROM 'file:///AuthorNodes.csv' AS row
WITH toInteger(row[0]) AS articleId, trim(row[1]) AS authorName
MATCH (ar:Article {id: articleId})
MERGE (au:Author {name: authorName})
CREATE (au)<-[:IS_WRITTEN_BY]-(ar);

// Import from Citations.csv (3933 ms)
LOAD CSV FROM 'file:///Citations.csv' AS row
FIELDTERMINATOR '\t'
WITH toInteger(row[0]) AS articleId, toInteger(row[1]) AS articleCitation 
MATCH (ar1:Article {id: articleId}), (ar2:Article {id: articleCitation})
CREATE (ar1)-[:CITES]->(ar2);


// CHECKS

// 29555 Articles
MATCH (n:Article) RETURN COUNT(n);

// 15420 Authors
MATCH (n:Author) RETURN COUNT(n);

// 836 Journals
MATCH (n:Journal) RETURN COUNT(n);

// 352807 citations
MATCH (n:Article)-[r:CITES]->() RETURN COUNT(r);


// QUERIES
// Model's relationships
// (au:Author)<-[:IS_WRITTEN_BY]-(ar:Article)-[:IS_PUBLISHED]->(j:Journal)
// (ar1:Article)-[:CITES]->(ar2:Article)

// Query 1
MATCH ()-[r:CITES]->()-[]->(au:Author)
RETURN au.name as Author, COUNT(r) as Citations
ORDER BY Citations DESC
LIMIT 5;

// Query 2
MATCH (au1:Author)<-[]-()-[]->(au2:Author)
WHERE au1 <> au2
RETURN au1.name as Author, COUNT(DISTINCT au2) as Collaborations
ORDER BY Collaborations DESC
LIMIT 5;

// Query 3
MATCH (au:Author)<-[r:IS_WRITTEN_BY]-(ar:Article)
WHERE NOT EXISTS((au)<-[r]-(ar)-[:IS_WRITTEN_BY]->(:Author))
RETURN au.name AS Author, COUNT(ar) AS Papers
ORDER BY Papers DESC
LIMIT 1;

// Query 4
// Author who wrote the most papers
MATCH (au:Author)<-[]-(ar:Article)
WHERE ar.year = 2001
RETURN au.name as Author, COUNT(ar) as Papers
ORDER BY Papers DESC
LIMIT 1;
// Author who published the most of them to a Journal (Venue)
MATCH (au:Author)<-[]-(ar:Article)-[]->(:Journal)
WHERE ar.year = 2001
RETURN au.name as Author, COUNT(ar) as Papers
ORDER BY Papers DESC
LIMIT 1;

// Query 5
MATCH (ar:Article)-[]->(j:Journal)
WHERE toUpper(ar.title) =~ ".*GRAVITY.*" AND ar.year = 1998
RETURN j.name as Journal, COUNT(ar) as Papers
ORDER BY Papers DESC
LIMIT 1;

// Query 6
MATCH ()-[r:CITES]->(ar:Article)
RETURN ar.title as Paper, COUNT(r) as Citations
ORDER BY Citations DESC
LIMIT 5;

// Query 7
MATCH (au:Author)<-[]-(ar:Article)
WHERE toUpper(ar.abstract) =~ ".*HOLOGRAPHY.*" AND toUpper(ar.abstract) =~ ".*ANTI[_\W\D\.\*\s]*DE[_\W\D\.\*\s]*SITTER.*"
WITH ar.title as Paper, COLLECT(au.name) as Authors
RETURN Authors, Paper;

// Query 8
MATCH p = shortestPath((au1:Author {name: 'C.N. Pope'})-[*]-(au2:Author {name: 'M. Schweda'}))
RETURN p, LENGTH(p) AS pathLength;

// Query 9
MATCH p = shortestPath((au1:Author {name: 'C.N. Pope'})-[:IS_WRITTEN_BY*]-(au2:Author {name: 'M. Schweda'}))
RETURN p, LENGTH(p) AS pathLength;

// Query 10
MATCH (startAuthor:Author {name: 'Edward Witten'}), (au:Author), p = shortestPath((startAuthor)-[:IS_WRITTEN_BY*]-(au))
WHERE au.name <> 'Edward Witten'
UNWIND nodes(p)[1..] AS article
WITH au.name AS Author, LENGTH(p) AS pathLength, COLLECT(article.title) AS Papers
WHERE LENGTH(p) > 25
RETURN Author, pathLength, Papers;

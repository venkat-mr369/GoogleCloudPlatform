**Cloud Spanner Architecture & Core Concepts**

**Google Cloud Spanner** is engineered as a globally distributed, strongly consistent, and highly available relational database. Its architecture merges the scalability of NoSQL systems with the transactional guarantees of traditional relational databases, enabling it to support mission-critical workloads at global scale.

### Core Architectural Components

- **Universe, Zones, and Spanservers**  
  Spanner is organized into a *universe* spanning multiple *zones* (geographically distributed locations). Each zone contains specialized servers called **spanservers** that manage data storage and transactional operations.

- **Data Sharding (Splits/Tablets)**  
  Data is partitioned into smaller units called **tablets** or **splits**. Each split holds a contiguous range of keys and is stored as key-value pairs with versioning timestamps. These splits are dynamically adjusted based on workload, ensuring balanced distribution and optimal performance.

- **Replication and Paxos Consensus**  
  Each split is **replicated** across multiple zones for high availability and fault tolerance. Spanner uses the **Paxos consensus algorithm** to coordinate replicas:
  - One replica acts as the **leader** (handles writes and coordinates updates).
  - Other replicas are **followers** (primarily serve reads).
  - Writes are committed only after a majority of replicas acknowledge, ensuring durability and consistency.

- **TrueTime API**  
  Spanner leverages **TrueTime**, a globally synchronized clock system using GPS and atomic clocks, to assign globally consistent timestamps to transactions. This enables *strong consistency* and *linearizability* across regions, ensuring all users see the same data at the same time.

- **Colossus Distributed File System**  
  All data is stored on **Colossus**, Google’s distributed file system, which provides high durability, scalability, and resilience to hardware failures.

- **Automatic Sharding and Load Balancing**  
  Spanner automatically shards data and redistributes splits as needed, maintaining even load and supporting seamless horizontal scaling.

### Transaction Management

- **Write Transactions**
  - The Paxos leader acquires write locks on target rows.
  - TrueTime assigns a globally consistent timestamp.
  - Transaction details are replicated to a majority of replicas.
  - The leader waits briefly to ensure all replicas are synchronized before committing.

- **Read Transactions**
  - **Strong Reads:** Always return the latest committed data, using TrueTime to verify consistency.
  - **Stale Reads:** Allow reading slightly older data for lower latency.

- **Multi-Split Transactions**
  - For transactions spanning multiple splits, Spanner uses a **two-phase commit protocol** to ensure atomicity and consistency across all involved splits.

### Key Concepts Table

| Concept                  | Description                                                                                  |
|--------------------------|----------------------------------------------------------------------------------------------|
| **Sharding/Splits**      | Data is automatically partitioned into splits/tablets for scalability and load balancing.    |
| **Replication**          | Each split is replicated across zones; Paxos ensures consistency and failover.               |
| **TrueTime**             | Global clock system for consistent, ordered transactions.                                    |
| **Spanservers**          | Specialized servers managing storage and transactional logic.                                |
| **Colossus**             | Underlying distributed file system for durable, scalable storage.                            |
| **Automatic Scaling**    | Data and compute resources scale horizontally as workload grows.                             |
| **High Availability**    | 99.999% uptime possible with multi-region deployments and automated failover.                |

**In summary:**  
Cloud Spanner’s architecture is built around global distribution, strong consistency (via TrueTime and Paxos), automatic sharding, and high availability. These core concepts allow it to deliver the scalability of NoSQL systems with the reliability and transactional integrity of relational databases, making it suitable for modern, globally distributed applications.

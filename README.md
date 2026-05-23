### Project: Real Estate Expert System & Auctioning in Prolog


# 🏠 Real Estate Expert System & Auctioning in Prolog

![Prolog](https://img.shields.io/badge/Prolog-Logic_Programming-blue.svg)
![SWI-Prolog](https://img.shields.io/badge/SWI--Prolog-Environment-red.svg)
![AI](https://img.shields.io/badge/AI-Expert_Systems-green.svg)

## 📖 Project Description
This project was implemented as part of the **"Computational Logic & Logic Programming"** course at the Informatics Department of AUTH. The goal is to develop an Expert System in **Prolog**, which matches the requirements of real estate clients with available apartments for rent.

The system reads data (facts) from separate knowledge base files (`houses.pl` for properties and `requests.pl` for clients) and uses logic rules to find the optimal matches.

## 🎯 System Features & Menu
The program offers an interactive menu with three (3) main options:

1. **Single Client Preferences (Interactive Mode):** The user inputs their details and criteria (e.g., budget, area, desired location). The system filters the `houses.pl` facts and displays all compatible houses, as well as the absolute best choice for that specific client.
2. **Bulk Client Preferences (Bulk Mode):** The system automatically scans the entire client database (`requests.pl`) and returns the list of houses that meet the prerequisites for each client individually.
3. **Client Selection via Auction (Auction Mode):** *The most advanced feature.* Since multiple clients might claim the same ideal house, the program sets up an "auction" using a weight/point system. It evaluates criteria like budget and extra funds the client is willing to spend, scores the "bidders", assigns each house to the highest bidder, and removes it from the list of available properties.

## 💻 Technologies & Code Structure
* **Language:** Prolog (usage of [SWI-Prolog](https://www.swi-prolog.org/) is recommended).
* **File Structure:**
  * `Real_Estate.pl` : The main script containing the logic, rules, menu, and auction algorithm.
  * `houses.pl`: The Knowledge Base with available properties.
  * `requests.pl`: The Knowledge Base with client profiles.

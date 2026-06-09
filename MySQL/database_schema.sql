create schema AegisLifeDB;
use AegisLifeDB;
select * from customer_master;
select * from claim_history;
select * from customer_feedback;
select * from agent_info;
select * from policy_details;

select count(*) as customer_count from customer_master;
select count(*) as agent_count from agent_info;
select count(*) as feedback_count from customer_feedback;
select count(*) as claim_count from claim_history;
select count(*) as policy_count from policy_details;

select customer_id,count(*) as cnt from customer_master
group by customer_id 
having count(*)>1;
-- There is no duplicate customer_id  in cutomer_master

select claim_id,count(*) as cnt from claim_history
group by claim_id
having count(*)>1;
-- There is no duplicate claim_id in claim_history

select feedback_id,count(*) as cnt from customer_feedback
group by feedback_id
having count(*)>1;
-- There is no duplicate feedback_id in feedback_history

select agent_id,count(*) as cnt from agent_info
group by agent_id
having count(*)>1;
-- There is no duplicate agent_id in agent_info

select policy_id,count(*) as cnt from policy_details
group by policy_id
having count(*)>1;
-- There is no duplicat policy_id in policy_details

-- Policies with invalid customers
 select count(*) as invalid_customer_refs
 from policy_details p
 left join customer_master c
 on c.customer_id=p.customer_id
 where c.customer_id is null ;
 -- There is no invalid customer in policies, it means policy belongs to valid customers
 
 -- Policies with invalid agents
 select count(*) as invalid_agent_refs
 from policy_details p
 left join agent_info a
 on a.agent_id=p.agent_id
 where a.agent_id is null ;
  -- There is no invalid agent  in policies, it means policy sold by register agents
  
  -- Claims with invalid policies
select count(*) as invalid_claims_refs
from  claim_history c
left join policy_details p
on c.policy_id=p.policy_id
where p.policy_id is null ;
-- there is no invalid_claims.

-- Feedback with invalid customers
 select count(*) as invalid_feedback_refs
 from customer_feedback c
 left join customer_master cm
 on c.customer_id=cm.customer_id
 where c.customer_id is null 
  and  cm.customer_id  is null;
 -- There is no invalis customere feedback.
 
 select * from customer_master;
select * from claim_history;
select * from customer_feedback;
select * from agent_info;
select * from policy_details;
SET SQL_SAFE_UPDATES = 0;
UPDATE policy_details
SET product_type = 'Property'
WHERE product_type = 'Properties';
SELECT gender, COUNT(*) FROM customer_master GROUP BY gender;
UPDATE customer_master
SET gender = 'Male'
WHERE gender = 'Mal' ;
UPDATE customer_master
SET gender = 'Male'
WHERE gender = 'males' ;
UPDATE customer_master
SET gender = 'Female'
WHERE gender = 'females' ; 

SELECT marital_status, COUNT(*) FROM customer_master GROUP BY marital_status;

SELECT occupation, COUNT(*) FROM customer_master GROUP BY occupation;

SELECT region, COUNT(*) FROM customer_master GROUP BY region;
UPDATE customer_master
SET region = 'South'
WHERE region ='souht'; 
UPDATE customer_master
SET region = 'West'
WHERE region ='Wset'; 

SELECT smoking_status, COUNT(*) FROM customer_master GROUP BY smoking_status;

SELECT pre_existing_illness, COUNT(*) FROM customer_master GROUP BY pre_existing_illness;

SELECT status, COUNT(*) FROM policy_details GROUP BY status;

SELECT claim_status, COUNT(*) FROM claim_history GROUP BY claim_status;
UPDATE claim_history
SET claim_status= 'Approved'
WHERE claim_status ='Aproval'; 
UPDATE claim_history
SET claim_status= 'Rejected'
WHERE claim_status ='Rejeted'; 

SELECT claim_type, COUNT(*) FROM claim_history GROUP BY claim_type;

SELECT fraud_flag, COUNT(*) FROM claim_history GROUP BY fraud_flag;

 -- Total Policies by Product
select product_type,count(*) as total_policy
from policy_details
group by product_type
order by count(*) desc;
-- Policy sales are relatively balanced across all five product categories, with Vehicle policies accounting for the highest share (591 policies) and Whole Life policies the lowest (540 policies).

--  Policy Status Analysis

SELECT
status,
COUNT(*) AS total_policies,
ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM policy_details),2) AS pct
FROM policy_details
GROUP BY status;
-- Policy statuses are relatively balanced across Active, Lapsed, and Cancelled categories. Active policies account for approximately 34% of the portfolio, indicating opportunities to improve customer retention and reduce policy attrition.

-- Claim Status Analysis
SELECT
    claim_status,
    COUNT(*) AS total_claims
FROM claim_history
GROUP BY claim_status;
-- Claim outcomes are fairly evenly distributed across Approved, Pending, and Rejected categories, suggesting no significant operational bias toward approval or rejection.

-- Product-wise Claim Amount
SELECT
    p.product_type,
    ROUND(SUM(c.claim_amount),2) AS total_claim_amount
FROM claim_history c
JOIN policy_details p
ON c.policy_id = p.policy_id
GROUP BY p.product_type
ORDER BY total_claim_amount DESC;
-- Health insurance generated the highest aggregate claim amount, indicating a higher financial exposure for the company in this product segment.

-- Region-wise Claim Analysis
SELECT
    cm.region,
    COUNT(ch.claim_id) AS total_claims,
    ROUND(SUM(ch.claim_amount),2) AS total_claim_amount
FROM customer_master cm
JOIN policy_details pd
ON cm.customer_id = pd.customer_id
JOIN claim_history ch
ON pd.policy_id = ch.policy_id
GROUP BY cm.region
ORDER BY total_claim_amount DESC;
-- Central region exhibits the highest claim burden and should be monitored for profitability and claim management efficiency.

-- Fraud Analysis
SELECT
fraud_flag,
COUNT(*) AS total_claims,
ROUND(COUNT(*)*100.0/
(
SELECT COUNT(*)
FROM claim_history
),2) AS percentage
FROM claim_history
GROUP BY fraud_flag;
-- Nearly half of all claims are marked with a fraud flag. Such a high proportion of potentially fraudulent claims represents a significant operational and financial risk. The company should prioritize fraud detection, claim verification controls, and targeted investigations to reduce unnecessary claim payouts.

-- Agent Productivity
SELECT
    agent_id,
    total_policies_sold,
    lapsed_policies,
    fraud_association,
    avg_premium_sold
FROM agent_info
ORDER BY total_policies_sold DESC
LIMIT 10;
SELECT
AVG(total_policies_sold) AS avg_policy_sold,
AVG(lapsed_policies) AS avg_lapsed,
AVG(fraud_association) AS avg_fraud_association
FROM agent_info;
-- Top 10 agents who sold most policies
-- The average agent sold approximately 176 policies. On average, agents are associated with 26 lapsed policies and about 5 fraud-linked claims. These benchmark values can be used to identify high-performing agents as well as agents requiring additional monitoring or training.

-- Customer Risk Analysis
SELECT
    CASE
        WHEN risk_score < 0.3 THEN 'Low Risk'
        WHEN risk_score < 0.7 THEN 'Medium Risk'
        ELSE 'High Risk'
    END AS risk_category,
    COUNT(*) AS customers
FROM customer_master
GROUP BY risk_category;
-- Approximately 69–70% of customers fall into the Medium Risk segment, while High Risk customers represent a smaller but potentially more costly population requiring closer monitoring.

-- Loss Ratio

SELECT
ROUND(
SUM(claim_amount) /
(
SELECT SUM(annual_premium)
FROM policy_details
),
2
) AS loss_ratio
FROM claim_history;
-- AegisLife's overall loss ratio is 4.71 (471%), indicating that claim payouts substantially exceed premium collections. For every ₹1 collected in premium, approximately ₹4.71 is paid out in claims. This suggests significant profitability concerns and highlights the need for deeper analysis by region, product type, and customer risk segment.

-- Claim Approval Rate
SELECT
ROUND(
SUM(CASE WHEN claim_status='Approved' THEN 1 ELSE 0 END)
*100.0/COUNT(*),
2
) AS approval_rate
FROM claim_history;
 -- Only 35.85% of submitted claims are approved, meaning nearly two-thirds of claims are either rejected or remain pending. This may indicate strict claim verification processes, incomplete documentation from policyholders, or operational inefficiencies in claims processing.
 
 -- Product-wise Loss Ratio
 SELECT
pd.product_type,
ROUND(
SUM(ch.claim_amount)
/ SUM(pd.annual_premium),
2
) AS loss_ratio
FROM policy_details pd
JOIN claim_history ch
ON pd.policy_id = ch.policy_id
GROUP BY pd.product_type
ORDER BY loss_ratio DESC;
-- Property insurance represents the highest financial risk for AegisLife, generating claim payouts that significantly exceed premium collections. This product line should be reviewed for pricing adequacy, underwriting standards, and claim verification controls.

-- Region-wise Loss Ratio
SELECT
cm.region,
ROUND(
SUM(ch.claim_amount)
/ SUM(pd.annual_premium),
2
) AS loss_ratio
FROM customer_master cm
JOIN policy_details pd
ON cm.customer_id = pd.customer_id
JOIN claim_history ch
ON pd.policy_id = ch.policy_id
GROUP BY cm.region
ORDER BY loss_ratio DESC;
-- Although loss ratios are relatively similar across regions, the South region exhibits the highest claim burden. Regional claim patterns should be monitored closely to identify operational or risk-related factors driving losses
 
 -- Policy Lapse Rate
  SELECT
ROUND(
SUM(CASE WHEN status='Lapsed' THEN 1 ELSE 0 END)
*100.0/COUNT(*),
2
) AS lapse_rate
FROM policy_details;
-- Nearly one-third of all policies have lapsed. This suggests customer retention challenges and may lead to reduced recurring premium revenue
 
 CREATE VIEW insurance_master AS
SELECT
    c.customer_id,
    c.age,
    c.gender,
    c.region,
    c.smoking_status,
    c.risk_score,

    p.policy_id,
    p.product_type,
    p.coverage_amount,
    p.annual_premium,
    p.status,

    ch.claim_id,
    ch.claim_amount,
    ch.claim_status,
    ch.claim_type,
    ch.fraud_flag,

    a.agent_id,
    a.total_policies_sold,
    a.lapsed_policies,
    a.fraud_association

FROM customer_master c
LEFT JOIN policy_details p
    ON c.customer_id = p.customer_id
LEFT JOIN claim_history ch
    ON p.policy_id = ch.policy_id
LEFT JOIN agent_info a
    ON p.agent_id = a.agent_id;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

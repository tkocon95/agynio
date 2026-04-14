-- Change channel_node_id and assigned_agent_node_id from uuid to text
ALTER TABLE "Thread" ALTER COLUMN channel_node_id TYPE text;
ALTER TABLE "Thread" ALTER COLUMN assigned_agent_node_id TYPE text;

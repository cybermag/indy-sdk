package org.hyperledger.indy.sdk.agent;

import org.hyperledger.indy.sdk.ErrorCode;
import org.hyperledger.indy.sdk.ErrorCodeMatcher;
import org.hyperledger.indy.sdk.agent.Agent.Connection;
import org.hyperledger.indy.sdk.agent.Agent.Listener;
import org.hyperledger.indy.sdk.signus.Signus;
import org.hyperledger.indy.sdk.signus.SignusResults;
import org.junit.Test;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;


public class AgentCloseListenerTest extends AgentIntegrationTest {

	private static CompletableFuture<Connection> serverToClientConnectionFuture = new CompletableFuture<Connection>();

	private static final AgentObservers.MessageObserver messageObserver = new AgentObservers.MessageObserver() {

		public void onMessage(Connection connection, String message) {

			System.out.println("Received message '" + message + "' on connection " + connection);
		}
	};

	private static final AgentObservers.MessageObserver messageObserverForIncoming = new AgentObservers.MessageObserver() {

		public void onMessage(Connection connection, String message) {

			System.out.println("Received message '" + message + "' on incoming connection " + connection);
		}
	};

	private static final AgentObservers.ConnectionObserver incomingConnectionObserver = new AgentObservers.ConnectionObserver() {

		public AgentObservers.MessageObserver onConnection(Listener listener, Connection connection, String senderDid, String receiverDid) {

			System.out.println("New connection " + connection);

			serverToClientConnectionFuture.complete(connection);

			return messageObserverForIncoming;
		}
	};

	@Test
	public void testAgentCloseConnectionWorksForOutgoing() throws Exception {

		thrown.expect(ExecutionException.class);
		thrown.expectCause(new ErrorCodeMatcher(ErrorCode.CommonInvalidStructure));

		String endpoint = "127.0.0.1:9704";

		SignusResults.CreateAndStoreMyDidResult myDid = Signus.createAndStoreMyDid(wallet, "{}").get();

		String identityJson = String.format("{\"did\":\"%s\", \"pk\":\"%s\", \"verkey\":\"%s\", \"endpoint\":\"%s\"}",
				myDid.getDid(), myDid.getPk(), myDid.getVerkey(), endpoint);
		Signus.storeTheirDid(wallet, identityJson).get();

		Listener activeListener = Agent.agentListen(endpoint, incomingConnectionObserver).get();

		activeListener.agentAddIdentity(pool, wallet, myDid.getDid()).get();

		Agent.agentConnect(pool, wallet, myDid.getDid(), myDid.getDid(), messageObserver).get();

		Connection serverToClientConnection = serverToClientConnectionFuture.get();

		activeListener.agentCloseListener().get();

		serverToClientConnection.agentSend("msg").get();
	}
}
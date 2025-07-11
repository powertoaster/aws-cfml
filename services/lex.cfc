component {

    variables.service = 'lex';

    public any function init(
        required any api,
        required struct settings
    ) {
        variables.api = arguments.api;
        variables.apiVersion = arguments.settings.apiVersion;

        return this;
    }

    /**
    * Removes session information for a specified bot, alias, and user ID.
    * You can use this operation to restart a conversation with a bot. When you remove a session, 
    * the entire history of the session is removed so that you can start again.
    *
    * You don't need to delete a session. Sessions have a time limit and will expire. 
    * Set the session time limit when you create the bot. The default is 5 minutes, but you can specify anything between 1 minute and 24 hours.
    *
    * If you specify a bot or alias ID that doesn't exist, you receive a BadRequestException.
    * If the locale doesn't exist in the bot, or if the locale hasn't been enables for the alias, you receive a BadRequestException.
    *
    * https://docs.aws.amazon.com/lexv2/latest/APIReference/API_runtime_DeleteSession.html
    *
    * @BotAliasId The alias identifier in use for the bot that contains the session data.
    * @BotId The identifier of the bot that contains the session data.
    * @LocaleId The locale where the session is in use.
    * @SessionId The identifier of the session to delete.
    */
    public any function deleteSession(
        required string BotAliasId,
        required string BotId,
        required string LocaleId,
        required string SessionId
    ){
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );

        var apiResponse = apiCall(
            deleteSession,
            'DELETE',
            '/bots/#BotId#/botAliases/#BotAliasId#/botLocales/#LocaleId#/sessions/#SessionId#'
        );

        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;

    }

    /**
    * Returns session information for a specified bot, alias, and user. 
    * For example, you can use this operation to retrieve session information for a user that has left a long-running session in use.
    * If the bot, alias, or session identifier doesn't exist, Amazon Lex V2 returns a BadRequestException. If the locale doesn't exist or is not enabled for the alias, you receive a BadRequestException.
    *
    * https://docs.aws.amazon.com/lexv2/latest/APIReference/API_runtime_GetSession.html
    *
    * @BotAliasId The alias identifier in use for the bot that contains the session data.
    * @BotId The identifier of the bot that contains the session data.
    * @LocaleId The locale where the session is in use.
    * @SessionId The identifier of the session to return.
    */
    public any function getSession(
        required string BotAliasId,
        required string BotId,
        required string LocaleId,
        required string SessionId
    ){
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );

        var apiResponse = apiCall(
            getSession,
            'GET',
            '/bots/#BotId#/botAliases/#BotAliasId#/botLocales/#LocaleId#/sessions/#SessionId#'
        );

        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;

    }

    /**
    * Creates a new session or modifies an existing session with an Amazon Lex V2 bot. Use this operation to enable your application to set the state of the bot.
    *
    * https://docs.aws.amazon.com/lexv2/latest/APIReference/API_runtime_PutSession.html
    *
    * @BotAliasId The alias identifier in use for the bot that contains the session data.
    * @BotId The identifier of the bot that contains the session data.
    * @LocaleId The locale where the session is in use.
    * @SessionId The identifier of the session to return.
    * @responseContentType The message that Amazon Lex V2 returns in the response can be either text or speech depending on the value of this parameter. 
    *   - If the value is text/plain; charset=utf-8, Amazon Lex V2 returns text in the response.
    */
    public any function putSession(
        required string BotAliasId,
        required string BotId,
        required string LocaleId,
        required string SessionId
    ){
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'messages': {},
            'requestAttributes': {},
            'sessionState': {}
        };

        if ( len( messages ) ) {
            payload[ 'messages' ] = Messages;
        }


        var apiResponse = apiCall(
            putSession,
            'POST',
            '/bots/#BotId#/botAliases/#BotAliasId#/botLocales/#LocaleId#/sessions/#SessionId#'
        );

        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;

    }

    /**
    * Sends user input to Amazon Lex V2. Client applications use this API to send requests to Amazon Lex V2 at runtime. 
    * Amazon Lex V2 then interprets the user input using the machine learning model that it build for the bot.
    * 
    * In response, Amazon Lex V2 returns the next message to convey to the user and an optional response card to display.
    * 
    * If the optional post-fulfillment response is specified, the messages are returned as follows. For more information, see PostFulfillmentStatusSpecification.
    * 
    * Success message - Returned if the Lambda function completes successfully and the intent state is fulfilled or ready fulfillment if the message is present.
    * Failed message - The failed message is returned if the Lambda function throws an exception or if the Lambda function returns a failed intent state without a message.
    * Timeout message - If you don't configure a timeout message and a timeout, and the Lambda function doesn't return within 30 seconds, the timeout message is returned. If you configure a timeout, the timeout message is returned when the period times out.
    * 
    * https://docs.aws.amazon.com/lexv2/latest/APIReference/API_runtime_RecognizeText.html
    *
    * @Text The Text to recognize.
    * @BotAliasId The alias identifier in use for the bot that processes the request.
    * @BotId The identifier of the bot that processes the request.
    * @LocaleId The locale where the session is in use.
    * @SessionId The identifier of the user session that is having the conversation.
    * 
    */
    public any function recognizeText (
        required string Text,
        required string BotAliasId,
        required string BotId,
        required string LocaleId,
        required string SessionId
    ) {
        var requestSettings = api.resolveRequestSettings( argumentCollection = arguments );
        var payload = {
            'text': Text
        };

        var apiResponse = apiCall(
            requestSettings,
            'POST',
            '/bots/#BotId#/botAliases/#BotAliasId#/botLocales/#LocaleId#/sessions/#SessionId#/text',
            payload
        );

        apiResponse[ 'data' ] = deserializeJSON( apiResponse.rawData );

        return apiResponse;
    }

    // private

    private string function getHost(
        required string region
    ) {
        return 'runtime-v2-lex' & '.' & arguments.region & '.amazonaws.com';
    }

    private any function apiCall(
        required struct requestSettings,
        string httpMethod = 'GET',
        string path = '/',
        struct payload = { },
        struct queryParams = { },
        struct headers = { }
    ) {
        var host = getHost( requestSettings.region );
        var payloadString = payload.isEmpty() ? '' : serializeJSON( payload );

        if ( !payload.isEmpty() ) headers[ 'Content-Type' ] = 'application/json';

        return api.call(
            variables.service,
            host,
            requestSettings.region,
            httpMethod,
            path,
            queryParams,
            headers,
            payloadString,
            requestSettings.awsCredentials
        );
    }

}
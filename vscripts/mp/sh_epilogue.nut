global function ShEpilogue_Init
global function ShEpilogue_RegisterNetworking

global function SetSetupNetwork_Epilogue
global function SetSetup_Epilogue
global function SetProcess_Epilogue

#if SERVER
global function SetValidationCheck_Epilogue
global function DoesEpilogueExist
#endif


                     

                                          
                                   
                                     

          
                                                      
                                                   
      

      







struct
{
	void functionref()	SetupNetwork_Epilogue
	void functionref()	Setup_Epilogue
	void functionref()	Process_EpilogueThink

	#if SERVER
		float timeForOutro
		bool functionref()	ValidationCheck_EpilogueThink
	#endif
} file


void function ShEpilogue_Init()
{
	PrecacheScriptString( "epilogue_evac_location" )
	AddCallback_GameStateEnter( eGameState.Epilogue, Callback_EpilogueEnter )

	if ( file.Setup_Epilogue != null )
		file.Setup_Epilogue()

	#if SERVER
		file.timeForOutro = GetCurrentPlaylistVarFloat( "epilogue_timeForOutro", 10.0 )
	#endif
}


void function ShEpilogue_RegisterNetworking()
{
	if ( file.SetupNetwork_Epilogue != null )
		file.SetupNetwork_Epilogue()
}









void function SetSetupNetwork_Epilogue( void functionref() func )
{
	file.SetupNetwork_Epilogue = func
}


void function SetSetup_Epilogue( void functionref() func )
{
	file.Setup_Epilogue = func
}


void function SetProcess_Epilogue( void functionref() func )
{
	file.Process_EpilogueThink = func
}


void function Callback_EpilogueEnter()
{
	thread EpilogueThink()
}


void function EpilogueThink()
{
	Assert( IsNewThread(), "Must be threaded off" )

	bool shouldProceedWithThink = false
	#if SERVER
		if ( file.ValidationCheck_EpilogueThink != null )
			shouldProceedWithThink = file.ValidationCheck_EpilogueThink()

		printf( "EPILOGUE: proceed with think is " + shouldProceedWithThink )
	#endif

	if ( file.Process_EpilogueThink != null && shouldProceedWithThink )
		waitthread file.Process_EpilogueThink()

	#if SERVER
		if ( shouldProceedWithThink )
			waitthread Epilogue_TransitionToResolutionWait()

		Signal( svGlobal.levelEnt, "StopTimedEvents" )
		SetGameState( eGameState.Resolution )
	#endif
}







#if SERVER
void function SetValidationCheck_Epilogue( bool functionref() func )
{
	file.ValidationCheck_EpilogueThink = func
}


void function Epilogue_TransitionToResolutionWait()
{
	Epilogue_PlayOutro_ForAllPlayers()
	wait file.timeForOutro
}


void function Epilogue_PlayOutro_ForAllPlayers()
{
	array<entity> players = GetPlayerArray()
	Epilogue_PlayOutro( players )
}


void function Epilogue_PlayOutro( array<entity> players )
{
	int winningTeam = GetWinningTeam()
	if ( winningTeam == -1 )
		return

	foreach( entity player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( IsValid( player ) )
		{
			// this will retrigger the loss music for the lossers as well as play the win music for the winner.
			// Can't use PlayMusicToPlayer(), because on the client, the music is played on the viewPlayer, so you to hear the wrong music if you are specating.
			StopAllMusicOnPlayer( player )
			Remote_CallFunction_NonReplay( player, "ServerCallback_PlayMatchEndMusic" )
			Remote_CallFunction_Replay( player, "ServerCallback_MatchEndAnnouncement", player.GetTeam() == winningTeam, winningTeam )
		}
	}
}


bool function DoesEpilogueExist()
{
	return file.Process_EpilogueThink != null
}
#endif












                     

                                                                                    
                                                                                    
                                                                                    

      
 
                  
                           
                        
                      
                          


                   
                 

                     
                            
                            

              



                                          
 
                                                                                                   
                                                                                                 
 



                                   
 
           
                                              

                                                              

                                                                                                         
                                                                                                   
                                                                                              
                                                                                                       
                                                                                    

                                                                                        
                                                       
                                                                      
       

           
                                                

                                                                               
                                                                                 
       

                                    
 


                                     
 
                                                

           
                                                            

                                    
                                              
   
                            
            

                                                                                           
   

                                                                                                       
       

           
                                                             
       
 


                                                 
 
                               
                                 
                                                                                                                                                                                                               
                                                                                                                                                       
           
                                          
                                                  
                                                                        
                                      
                                                              
                                                           

                                            
                                                    
                                                                            
                                                                                                  
                                                                  
                                                             
       

           
                                                            
                                                            
                                             

                                                               
                                                               
                                               
       

                                             

                                                  
                                                    
 




                                                               
                                                    
                                                                                        




          
                                                     
 
                                                                                     
                                                                                 
                                                               
                                                                 
                                                             
                                                               
         

                                                                 
                                                 
                                                  
                                              
                                                
         

                                          
  
                                                             
                                                  
  
 


                                             
 
                                        
                                                                                  
                                           
 


                                           
 
                                   
                                                  
                                                               

                                   

                                                                                        
                               
  
                                    
        
  

                                             
  
                           
           

                                                                                             
  
 


                                                                                      
 
                         
                               

                                        
  
                                                        
        
  
 


                                                                                 
 
                                       
                                                                           

                   
                    
                                   
                                            
  
                            
   
                    
        
   
  

                                           
  
                                                                             
                                
                           
                                          
                                                                           
                
                
                 
                 
                                               
                                                                                               
  

                                            
 


                                                                                   
 

 


                                                                  
 
                                                     
                                                      

                                                                
                                     

                                        
  
                                                        
        
  
 


                                              
 
                                         
                                             
             

                   
                    
                                   
                                            
  
                            
   
                    
        
   
  

                                        
                                                           
             

                                                                              
                              
                                                        
  
                           
           

                                            
           

                         
  

                         
 
      






          
                                                        
 
                               
 


                                            
 
                      
        

                                                                    
        

                                                
             

                      
        

                            

                                   
                                                                   

                        
  
                                                  
                                                                      

                                                   
                                                                     
   
                                                                                    
                                                                                                                                                
   

             
  
 


                                          
 
                                                         
 


                                                                       
 
                                                                   

                                                                                                                                          
                                                                                                                                                                                                                                                                                                   
                                                                        
                                                                         
                                            
                                                                                                      
                                                                               
                            
                                                            
 

                                                                    
 
                                                                   

                                                                                                                                                    
                                                                         
                                                                        
                                                                
                                            
                                                                                                      
                                                                               
                                                                                                                                                                    
                                                                      
                            
                                                            
 
      




                            
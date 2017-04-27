
//
// Assembly functions
//
extern "C" {
   void initializePanel();
//   void operatePanel();
//   void returnPanel();
//   void resetPanel();
//   void parkPanel();
//   int  queryPanel(byte lightVals[]);
}

int numVals = 0;
byte lightVals[25];

//
// Code that uses the functions
//
void setup()
{
   Serial.begin(9600);
   initializePanel();
}

//
// In order to process user command AND operate the
// solar panel, the loop function needs to poll for
// user input and then invoke "operatePanel" to allow
// the panel operation code to do what it needs to 
// for ONE STEP. You should not do a continuous loop
// in your assembly code, but just cycle through
// checking everything you need to one time, and then
// returning back and allowing the loop function here
// continue.
//
void loop()
{
 
//   char cmd[32];
//
//   delayMicroseconds(100); // no need to go too fast
//
//   cmd[0] = '\0'; // reset string to empty
//   if (readUserCommand(cmd)) {
//      // this if statement just shows that command strings
//      // are being read; it serves no other useful purpose
//      // and can be deleted or commented out
//      Serial.print("User command is (");
//      Serial.print(cmd);
//      Serial.println(")");
//   }
//   // The conditions below recognize each individual
//   // command string; all they do now is print, but you
//   // will need to add code to do the proper actions
//   if (!strcmp(cmd,"reset")) {
//      Serial.println("Do reset!");
//      resetPanel();
//   } else if (!strcmp(cmd,"park")) {
//      Serial.println("Do park!");
//      parkPanel();
//   } else if (!strcmp(cmd,"query")) {
//      Serial.println("Do query!");
//      numVals = queryPanel(lightVals);
//      for(int i = 0; i < numVals; i++)
//        Serial.println(lightVals[i]);
//      Serial.println();  
//      Serial.println(numVals);                
//   }
   // This invokes your assembly code to do ONE STEP of
   // operating the solar panel
   //operatePanel();
}

//
// If there is any serial input, read it into the
// given array; the array MUST be at least 32 chars long
// - returns true if a string is read in, false otherwise
// (note: 9600baud (bits per second) is slow so we need
//  to have delays so that we don't go too fast)
//
boolean readUserCommand(char cmdString[])
{
   if (!Serial.available())
      return false;
   delayMicroseconds(5000); // allow serial to catch up
   int i=0;
   while (i < 31) {
      cmdString[i++] = Serial.read();
      delayMicroseconds(1000);
      if (!Serial.available())
         break; // quit when no more input
   }
   cmdString[i] = '\0'; // null-terminate the string
   while (Serial.available()) {
      Serial.read(); // flush any remain input (more than 31 chars)
      delayMicroseconds(1000);
   }
   return true;
}


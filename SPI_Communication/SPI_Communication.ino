
#define DATAOUT 11//MOSI
#define DATAIN  12//MISO 
#define SPICLOCK  13//sck
#define SLAVESELECT 10//ss

#define LED_YELLOW_POS 2
#define LED_YELLOW_NEG 3
#define LED_RED_POS 4
#define LED_RED_NEG 5
#define LED_GREEN_POS 6
#define LED_GREEN_NEG 7

//opcodes
#define WRITE B11111110
#define READ B00000001


byte memory_output_data;
byte memory_input_data=0;
byte clr; // dummy variable, for clearing registers during initialization
byte address=0;
boolean passed = true;

const int num_test_cases = 12;
char test_cases[num_test_cases] = {B00000001,B00000010,B00000100,B00001000,B00010000,B00100000,B01000000,B10000000,B11001100,B00110011,B10101010,B01010101};


char spi_transfer(volatile char data)
{
  SPDR = data;                    // Start the transmission
  while (!(SPSR & (1<<SPIF)))     // Wait the end of the transmission
  {
  };
  return SPDR;                    // return the received byte
}

void setup()
{
  Serial.begin(115200);

  pinMode(DATAOUT, OUTPUT);
  pinMode(DATAIN, INPUT);
  pinMode(SPICLOCK,OUTPUT);
  pinMode(SLAVESELECT,OUTPUT);
  digitalWrite(SLAVESELECT,HIGH); //disable device
  
  // yellow light
  pinMode(LED_YELLOW_POS, OUTPUT);
  pinMode(LED_YELLOW_NEG, OUTPUT);
  digitalWrite(LED_YELLOW_POS, HIGH);
  digitalWrite(LED_YELLOW_NEG, LOW);
  
  // green light
  pinMode(LED_GREEN_POS, OUTPUT);
  pinMode(LED_GREEN_NEG, OUTPUT);
  
  // red light
  pinMode(LED_RED_POS, OUTPUT);
  pinMode(LED_RED_NEG, OUTPUT);
  
  
  //SPCR = B01010011;
    SPCR = B01010010;
  //interrupt disabled,spi enabled,msb 1st,master,clk low when idle,
  //sample on leading edge of clk,system clock = 500Khz
  //SPCR = (1<<SPE)|(1<<MSTR);
  clr=SPSR; // wipe out whatever was in there before
  clr=SPDR;
  //SPSR = B00000000; // double transmission rate.
  SPSR = B00000001; // double transmission rate.
  delay(10);  
  

  Serial.println("Beginning Exaustive Test");
  
  // write all registers to 0
  for (int counter =0; counter < 128; counter ++) {
    writeData(0, counter);
    //Serial.println(counter, DEC);
  }
  //Serial.println("Completed writing zeros. debugging only");
  // read all registers, check that they are all 0.
  for (int counter =0; counter < 128; counter ++) {
    if (readData(counter) != 0) { passed = false;}
    //Serial.println(counter, DEC);
  }
  Serial.println("Wrote all registers to zero, read them back");
  if (passed){Serial.println("PASSED");}else{Serial.println("FAILED");}
  // for each register, write a handful of special cases, and a handful of random cases, then read the entire register and make sure that one is what we expect and the others are all still zero
  for (int counter_outer =0; counter_outer < 128; counter_outer ++) {
    Serial.print("Testing REG ");
    Serial.print(counter_outer);
    Serial.println(" For special and random cases");
    
    // now, for the current register, test all cases
    for (int counter_test_case = 0; counter_test_case < num_test_cases; counter_test_case ++) {
      //Serial.println();
      //Serial.println(counter_test_case);
      //Serial.println();
      // one case
      writeData(test_cases[counter_test_case], counter_outer);
      // now check that it was written correctly
      for (int counter_inner =0; counter_inner < 128; counter_inner ++) {
        if (counter_inner == counter_outer) { // this is the one register that we wrote to!
          char temp = readData(counter_inner);
          if (temp != test_cases[counter_test_case]) { passed = false; Serial.println("FAILURE case detected!!"); 
              Serial.print("Register "); Serial.print(counter_inner, DEC); Serial.print(" has failed to write "); Serial.print(test_cases[counter_test_case], BIN); Serial.print(" Instead we got: "); Serial.println(temp, BIN);}
        }
        else {// any of the other registers, should be zero
          if (readData(counter_inner) != 0) { passed = false; Serial.println("FAILURE case detected!!");
              Serial.print("Register "); Serial.print(counter_inner, DEC); Serial.print(" was not zero; register "); Serial.print(counter_outer, DEC); Serial.print(" was written with "); Serial.println(test_cases[counter_test_case], BIN);} 
        }
      }
    }
    writeData(0, counter_outer); // we have finished all cases for this register, so return its value to zero.
  }
  
  Serial.println("Special and Random case testing completed!");
  if (passed){
    Serial.println("PASSED"); 
    digitalWrite(LED_GREEN_POS, HIGH);
    digitalWrite(LED_GREEN_NEG, LOW);
  }  
  else{
    Serial.println("FAILED");
    digitalWrite(LED_RED_POS, HIGH);
    digitalWrite(LED_RED_NEG, LOW);
  }
  // turn off the yellow light
  digitalWrite(LED_YELLOW_POS, LOW);  
}






void writeData(char data, char address){
  digitalWrite(SLAVESELECT,LOW);
  address = address<<1; // move the 7 bits over by one so that they are the MSBs rather than the LSBs.
  address = address & WRITE; // set the lowest bit to 0, to indicate a write
  spi_transfer(address); // write command byte
  spi_transfer(data); //send data byte
  digitalWrite(SLAVESELECT,HIGH);
  delayMicroseconds(10);
}

char readData(int address){
  char myData;
  digitalWrite(SLAVESELECT,LOW);
  address = address<<1; // move the 7 bits over by one so that they are the MSBs rather than the LSBs.
  address = address | READ; // set the lowest bit to 1, to indicate a read
  spi_transfer(address); // write command byte
  myData = spi_transfer(0xFF); //get data byte, transmit garbage (the chip isn't listening to us)
  digitalWrite(SLAVESELECT,HIGH);
  delayMicroseconds(10);
  return myData;
}



void loop()
{
  
  delay(1000);
}


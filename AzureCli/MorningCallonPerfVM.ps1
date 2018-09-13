
 

 
  Select-AzureRmContext Context1 -Scope Process

  $res_grp = "tmp2","tmp3"

  $vm_list=""
  $stats 
  $starting="0"

 
 function start_vms()
 { 
   
   
     for($n=0; $n -le $res_grp.Count-1; $n++)
     {
       $vm_list=$(az vm list -g $res_grp[$n] --query '[].name')
       #$vm_ids= $(az vm list -g $res_grp[$n] --query '[].id')
       $g= $res_grp[$n]
       $vm_list= $vm_list.Trim("[").Trim("]")
       Write-Host $vm_list

          for($i=1; $i -le $vm_list.Split(",").Count-1; $i++)
            { 
                #Write-Host  $vm_list.Split(",").Trim()[$i] 
                [string]$a = $vm_list.Split(",").Trim()[$i]
                #$b = $vm_ids.Split(",").Trim()[$i] 
                

                if($a -notlike $null)
                {
                #Write-Host $a
                $stats = "$(az vm get-instance-view -g "$g" --name "$a" --query "instanceView.statuses[1].displayStatus" )" 
                Write-Host "$a : $stats" 
                }
                
                
                if ( $stats -match "VM deallocated"  -or  $stats -match "VM stopped")
                { 
                    Write-Host "VM is stopped, and it will be started" 
                    az vm start -g $g -n $a --no-wait
                    $starting="1" 
                } 
                
            } 
            
         }
       
      
    
 }

 
 start_vms
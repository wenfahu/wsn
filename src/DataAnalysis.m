%data is in workspace
[m,n]=size(data);

%sort according to time
for i=1:m
    for j=i:m
        if data(i,n) > data(j,n)
            data([i,j],:) = data([j,i],:);
        end
    end
end

%calculate packet loss rate
lossRate1 = 0;                   %the loss rate of node1
lossRate2 = 0;                   %the loss rate of node2
counterMin1 = 100000000;
counterMax1 = 0;
counterMin2 = 100000000;
counterMax2 = 0;
num1 = 0;
num2 = 0;

for i=1:m
    if data(i,1) == 1
        num1 = num1 + 1;
        if data(i,2) < counterMin1
            counterMin1 = data(i,2);
        end
        if data(i,2) > counterMax1
            counterMax1 = data(i,2);
        end
    end
    if data(i,1) == 2
        num2 = num2 + 1;
        if data(i,2) < counterMin2
            counterMin2 = data(i,2);
        end
        if data(i,2) > counterMax2
            counterMax2 = data(i,2);
        end
    end
end

lossRate1 = 1 - num1 / (counterMax1 - counterMin1 + 1);
lossRate2 = 1 - num2 / (counterMax2 - counterMin2 + 1);

%draw graph
L1 = (data(:,1) == 1);
L2 = (data(:,1) == 2);
data1 = data(L1,:);
data2 = data(L2,:);

%temperature
x1 = data1(:,6);
tmp1 = data1(:,3);
t1 = [];
averageTmp1 = [];
v = 0;
n1 = 0;
length = size(x1);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t1 = [t1, x1(i)];
        v = v + tmp1(i);
    else
        if x1(i) ~= x1(i-1)
            averageTmp1 = [averageTmp1, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + tmp1(i);
        end
    end
    if i == n
        averageTmp1 = [averageTmp1, v / n1];
    end
end

x2 = data2(:,6);
tmp2 = data2(:,3);
t2 = [];
averageTmp2 = [];
v = 0;
n1 = 0;
length = size(x2);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t2 = [t2, x2(i)];
        v = v + tmp1(i);
    else
        if x2(i) ~= x2(i-1)
            averageTmp2 = [averageTmp2, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + tmp1(i);
        end
    end
    if i == n
        averageTmp2 = [averageTmp2, v / n1];
    end
end

figure('Name', 'Temperature');
plot(t1,averageTmp1,'-r',t2, averageTmp2,'-b');
scrsz = get(0,'ScreenSize');
set(gcf,'Position',scrsz);

%humidity
x1 = data1(:,6);
hmd1 = data1(:,4);
t1 = [];
averageHmd1 = [];
v = 0;
n1 = 0;
length = size(x1);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t1 = [t1, x1(i)];
        v = v + hmd1(i);
    else
        if x1(i) ~= x1(i-1)
            averageHmd1 = [averageHmd1, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + hmd1(i);
        end
    end
    if i == n
        averageHmd1 = [averageHmd1, v / n1];
    end
end

x2 = data2(:,6);
Hmd2 = data2(:,4);
t2 = [];
averageHmd2 = [];
v = 0;
n1 = 0;
length = size(x2);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t2 = [t2, x2(i)];
        v = v + hmd1(i);
    else
        if x2(i) ~= x2(i-1)
            averageHmd2 = [averageHmd2, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + hmd1(i);
        end
    end
    if i == n
        averageHmd2 = [averageHmd2, v / n1];
    end
end
      
figure('Name', 'Humidity');
plot(t1,averageHmd1,'-r',t2, averageHmd2,'-b');
set(gcf,'Position',scrsz);


%light
x1 = data1(:,6);
lht1 = data1(:,5);
t1 = [];
averageLht1 = [];
v = 0;
n1 = 0;
length = size(x1);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t1 = [t1, x1(i)];
        v = v + lht1(i);
    else
        if x1(i) ~= x1(i-1)
            averageLht1 = [averageLht1, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + lht1(i);
        end
    end
    if i == n
        averageLht1 = [averageLht1, v / n1];
    end
end

x2 = data2(:,6);
Lht2 = data2(:,4);
t2 = [];
averageLht2 = [];
v = 0;
n1 = 0;
length = size(x2);

for i=1:length
    if n1 == 0
        n1 = n1 + 1;
        t2 = [t2, x2(i)];
        v = v + lht1(i);
    else
        if x2(i) ~= x2(i-1)
            averageLht2 = [averageLht2, v / n1];
            v = 0;
            n1 = 0;
        else
            n1 = n1 + 1;
            v = v + lht1(i);
        end
    end
    if i == n
        averageLht2 = [averageLht2, v / n1];
    end
end
   
figure('Name', 'Light');
plot(t1,averageLht1,'-r',t2, averageLht2,'-b');
set(gcf,'Position',scrsz);

 


    